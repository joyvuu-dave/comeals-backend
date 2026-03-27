# Comeals Billing System - Analysis & Remediation Plan

## 1. Application Overview

Comeals is a meal management system for co-housing communities. Residents sign up for communal dinners (typically 3x/week), volunteer to cook, and the cost of each meal is split among attendees. The system tracks who attended, who cooked, what each cook spent, and calculates balances so the community can periodically settle up.

### Core Domain Concepts

| Concept | Description |
|---------|-------------|
| **Meal** | A dinner event on a specific date. Has attendees (residents + guests) and cooks (who submit bills). |
| **Bill** | A cook's expense for a meal. One bill per cook per meal. Stores `amount` in dollars as DECIMAL(12,8). |
| **MealResident** | A resident's attendance at a meal. Captures the resident's `multiplier` at time of signup. |
| **Guest** | A non-resident brought by a resident. Has a `multiplier` (2=adult, 1=child). The hosting resident is charged for their guest. |
| **Multiplier** | A pricing weight. Adults=2, children=1. Used to split costs proportionally (adults pay 2x what children pay). |
| **Reconciliation** | A billing period. Meals are assigned to a reconciliation. Balances are calculated per-reconciliation. |
| **Rotation** | A scheduling group of ~12 meals used to organize cooking assignments. Distinct from reconciliation. |
| **Unit** | A household/apartment. Contains one or more residents. |
| **Community** | The co-housing community. Has a cost `cap` (max per-multiplier-unit cost). |

### How Cost Splitting Should Work (Conceptually)

1. Cook(s) buy groceries and submit their actual cost as a bill
2. The total meal cost is the sum of all bills
3. Each attendee's share = (total cost / total multiplier units) * their multiplier
4. Cooks get credited (reimbursed) and attendees get debited (charged)
5. A cook who also attends has both a credit and a debit, which partially cancel out
6. Periodically, balances are tallied and residents settle up (those with negative balances pay, those with positive balances receive)

---

## 2. Current Implementation

### 2.1 Cost Flow

```
Cook submits bill ($50.00)
  |
  v
Bill.amount = 50.00000000  (DECIMAL(12,8), dollars)
  |
  v
Meal.total_cost = SUM of bill.amount WHERE no_cost = false  (computed via SQL, not cached)
  |
  v
Meal.effective_total_cost = MIN(total_cost, max_cost) when capped, else total_cost
  |
  v
Meal.unit_cost = effective_total_cost / meal.multiplier  (BigDecimal division, full precision)
  |
  v
MealResident.cost = meal.unit_cost * meal_resident.multiplier
Guest.cost = meal.unit_cost * guest.multiplier
```

Cook reimbursement equals exactly what they spent — no rounding up, no phantom money.

### 2.2 Balance Calculation

```ruby
# Resident model — uses unreconciled scope (reconciliation_id IS NULL)
balance = bill_reimbursements - meal_resident_costs - guest_costs

where:
  bill_reimbursements = SQL SUM of bill.amount for unreconciled meals (no_cost = false)
  meal_resident_costs = SUM of meal.unit_cost * multiplier for unreconciled meals
  guest_costs         = SUM of meal.unit_cost * guest.multiplier for unreconciled meals
```

Balances are refreshed daily by `rake billing:recalculate` and stored in the `resident_balances` table (a materialized cache). Full precision is maintained throughout; rounding to cents occurs only at reconciliation time using banker's rounding (ROUND_HALF_EVEN).

### 2.3 What Was Removed

The following have been eliminated from the codebase:

- **counter_culture gem** — removed entirely. All derived values are computed from source data (SQL SUM/COUNT queries or Ruby enumeration).
- **Cached financial columns** — `meals.cost`, `residents.bill_costs`, `residents.balance_is_dirty` dropped. Non-financial counter caches (`meals.bills_count`, `meals.meal_residents_count`, etc.) also removed; counts are now computed on read.
- **money-rails gem** — removed. Financial values use raw `DECIMAL(12,8)` + `BigDecimal`.
- **Integer cents storage** — `bills.amount_cents` (integer) replaced by `bills.amount` (DECIMAL dollars).
- **Reimbursement rounding** — `reimburseable_amount` (which rounded up to make integer division exact) eliminated. BigDecimal division handles remainders at full precision.

---

## 3. Identified Bugs and Issues

All bugs below have been **resolved** in the `billing-system-remediation` branch.

### BUG 1: Hard-coded `reconciliation_id == 3` — RESOLVED

Balance calculations were hardcoded to `reconciliation_id == 3`. Now uses `Meal.unreconciled` scope (`reconciliation_id IS NULL`). The `update_bills` guard checks `reconciliation_id.present?`.

### BUG 2: Reimbursement Exceeds Actual Cost — RESOLVED

The `reimburseable_amount` method (which rounded up to make integer division exact) has been removed. Cooks are reimbursed exactly `bill.amount`. BigDecimal division handles remainders at full precision — no phantom money.

### BUG 3: Counter Culture Values Drift Over Time — RESOLVED

The `counter_culture` gem has been removed entirely. All derived values (costs, counts, multiplier sums) are computed from source data via SQL queries or Ruby enumeration. The daily `billing:recalculate` rake task refreshes the `resident_balances` cache.

### BUG 4: `no_cost` Bills Not Properly Handled — RESOLVED

`Bill#effective_amount` returns 0 when `no_cost` is true. `Meal#total_cost` filters with `bills.where(no_cost: false).sum(:amount)`. Semantics: `no_cost = true` means "this cook volunteered but attendees should not be charged for this bill."

### BUG 5: Existing Test Passes for Wrong Reason — RESOLVED

The balance test now creates unreconciled meals with bills and attendees, and verifies the calculated balance matches expected values. 124 model/unit tests + 14 request specs now cover the billing system.

### BUG 6: Meal.collected Can Exceed Actual Cost — RESOLVED

With BigDecimal division, `collected` (= `unit_cost * multiplier`) equals `effective_total_cost` exactly. No rounding inflation.

### BUG 7: Multiple Bills Per Meal - Rounding Compounds — RESOLVED

Eliminated by switching to BigDecimal. Per-bill `unit_cost` is computed at full precision. No per-bill rounding step exists.

### BUG 8: `meals_attended` Uses Different Scope Than Balance — RESOLVED

Both `meals_attended` and balance methods now use the same `Meal.unreconciled` scope.

### BUG 9: Reconciliation Creation is Manual and Incomplete — RESOLVED

`Reconciliation#assign_meals` (after_commit on create) assigns all unreconciled meals with bills. `Reconciliation#settlement_balances` computes final per-resident balances rounded to cents using banker's rounding. Reconciled meals are locked from further cost changes via the `update_bills` guard.

### ISSUE 10: Integer Cents Loses Precision in Division — RESOLVED

All financial columns use `DECIMAL(12,8)`. All Ruby arithmetic uses `BigDecimal`. Division remainders are preserved at sub-micro-cent precision. Rounding to cents occurs only at reconciliation settlement time.

---

## 4. Design Decisions (Finalized)

### Decision 1: Fractional cents with high-precision DECIMAL

**DECIDED: Use PostgreSQL `DECIMAL(12, 8)` for all financial columns. Use `BigDecimal` in Ruby. Never Float.**

Rationale: This is what banks and accounting systems do. PostgreSQL's `NUMERIC`/`DECIMAL` type performs exact arithmetic — no IEEE 754 floating-point errors. 8 decimal places gives sub-micro-cent precision, which makes division remainders negligible.

The model:
- **Input** (cook's receipt): Always whole cents — you can't spend half a cent at a store. Stored as `DECIMAL(12, 8)` with zero fractional part for type consistency.
- **Intermediate** (per-unit cost, individual charges): Full `DECIMAL(12, 8)` precision. No rounding.
- **Settlement** (reconciliation): Rounded to whole cents using **banker's rounding** (`BigDecimal::ROUND_HALF_EVEN`), the standard in finance per IEEE 754.

Example: $50.00 meal, 7 multiplier units
- `unit_cost = 50.00 / 7 = 7.14285714` (stored at full precision)
- Adult (mult 2) charge: `7.14285714 * 2 = 14.28571428`
- At reconciliation: rounded to `$14.29` (banker's rounding)
- Total collected: varies by exact attendee mix, but tracks reality to sub-penny precision

### Decision 2: Balance scope = current (unreconciled) period

**DECIDED: Balances cover unreconciled meals only (reconciliation_id IS NULL).**

After reconciliation, those meals are "closed." Balances reset for the next period. Residents settle the rounded-to-cents amount at reconciliation time. Simple mental model: "what do I owe or am owed for this batch of meals?"

### Decision 3: Balances computed daily via rake task

**DECIDED: A daily rake task recomputes all balances from source data.**

Source of truth: bills + meal_residents + guests records. The `resident_balances` table is a materialized cache that can be rebuilt from scratch at any time. No counter_culture for financial data. No real-time balance updates. Balances may be up to ~24 hours stale — this is acceptable for a meal system that reconciles periodically.

### Decision 4: Manual reconciliation trigger

**DECIDED: Admin manually triggers reconciliation. System auto-assigns eligible meals.**

When triggered:
1. Create a Reconciliation record
2. Assign all unreconciled meals that have at least one bill
3. Compute final balances, round to cents (banker's rounding)
4. Lock those meals from further cost changes
5. Send notification emails

### Decision 5: Rotations and reconciliations are fully decoupled

**DECIDED.** Rotations = cooking schedule. Reconciliations = billing periods. No relationship between them.

### Decision 6: Cost cap (still open)

**STILL NEEDS INPUT:** Is the cap per-adult-unit or per-multiplier-unit? Currently it's per-multiplier-unit (cap of $2.50 means a child pays $2.50 max, adult pays $5.00 max). Is this the intended behavior, or should the cap be per-person regardless of multiplier?

---

## 5. Remediation — Completed

All four phases have been implemented in the `billing-system-remediation` branch:

1. **Phase 1** — Fixed hardcoded `reconciliation_id == 3` to use `Meal.unreconciled` scope
2. **Phase 2** — Migrated to `DECIMAL(12,8)` + `BigDecimal`, removed `money-rails`, removed reimbursement rounding
3. **Phase 3** — Removed `counter_culture` gem entirely, added `billing:recalculate` daily rake task
4. **Phase 4** — Automated reconciliation lifecycle with `assign_meals` + `settlement_balances` (banker's rounding)

**Frontend** (`comeals-ui`) updated in parallel: `amount_cents` (integer) replaced with `amount` (decimal dollars) in bill store, data store, and API calls.

**Test coverage:** 124 model/unit tests + 14 request specs = 138 total tests, 0 failures.

---

## 6. Environment

- **Ruby:** 3.2.10 (managed by rbenv)
- **Database:** PostgreSQL (Heroku Postgres 16.10 in production)
- **Tests:** `bundle exec rspec` — 138 tests (124 model + 14 request specs), 0 failures
- **Rake tasks:** `rake billing:recalculate` (daily balance refresh), `rake reconciliations:create` (manual billing period close)

---

## 7. Open Questions

1. **How often does the community reconcile?** (Every N meals? Monthly? Quarterly?)
2. **Is the cap feature actively used?** (Production data shows community cap is NULL — no cap set.)
3. **Decision 6:** Is the cap per-adult-unit or per-multiplier-unit? (Current implementation: per-multiplier-unit.)

---

## 8. Key Files Reference

### Financial Logic
- `app/models/bill.rb` — effective_amount, unit_cost, capped_amount
- `app/models/meal.rb` — multiplier, total_cost, effective_total_cost, unit_cost, max_cost
- `app/models/resident.rb` — calc_balance, bill_reimbursements, meal_resident_costs, guest_costs
- `app/models/meal_resident.rb` — cost
- `app/models/guest.rb` — cost
- `app/models/reconciliation.rb` — assign_meals, settlement_balances
- `app/controllers/api/v1/meals_controller.rb` — update_bills

### Tests
- `spec/models/bill_spec.rb` — unit_cost, effective_amount, capped_amount
- `spec/models/meal_spec.rb` — total_cost, unit_cost, multiplier, capped meals
- `spec/models/resident_spec.rb` — calc_balance, bill_reimbursements, meal_resident_costs, guest_costs
- `spec/models/reconciliation_spec.rb` — assign_meals, settlement_balances
- `spec/requests/api/v1/update_bills_spec.rb` — auth, authorization, reconciled guard, malformed input, bill updates

### Admin
- `app/admin/bill.rb`, `app/admin/meal.rb`, `app/admin/resident.rb`

### Frontend (../comeals-ui)
- `src/stores/bill.js` — bill model, amount validation
- `src/stores/data_store.js` — submitBills, loadDataAsync
- `src/components/meal/cooks_box.jsx` — bill entry UI
