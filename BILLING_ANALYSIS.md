# Comeals Billing System - Analysis & Remediation Plan

## 1. Application Overview

Comeals is a meal management system for co-housing communities. Residents sign up for communal dinners (typically 3x/week), volunteer to cook, and the cost of each meal is split among attendees. The system tracks who attended, who cooked, what each cook spent, and calculates balances so the community can periodically settle up.

### Core Domain Concepts

| Concept | Description |
|---------|-------------|
| **Meal** | A dinner event on a specific date. Has attendees (residents + guests) and cooks (who submit bills). |
| **Bill** | A cook's expense for a meal. One bill per cook per meal. Stores `amount_cents`. |
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

## 2. Current Implementation - How It Actually Works

### 2.1 Cost Flow (Current)

```
Cook submits bill ($50.00 = 5000 cents)
  |
  v
Bill.amount_cents = 5000
  |
  v
counter_culture adds 5000 to Meal.cost
  |
  v
Bill.max_amount = amount_cents (if no cap) OR proportional cap
  |
  v
Bill.reimburseable_amount = max_amount rounded UP to nearest multiple of meal.multiplier
  |                         (e.g., 5000 with multiplier 7 -> 5005)
  v
Bill.unit_cost = reimburseable_amount / meal.multiplier  (INTEGER division)
  |
  v
Meal.unit_cost = SUM of all bill.unit_cost values
  |
  v
MealResident.cost = meal.unit_cost * meal_resident.multiplier
Guest.cost = meal.unit_cost * guest.multiplier
```

### 2.2 Balance Calculation (Current)

```ruby
# Resident model (HARDCODED to reconciliation_id == 3)
balance = bill_reimbursements - meal_resident_costs - guest_costs

where:
  bill_reimbursements = SUM of bill.reimburseable_amount (for meals in reconciliation 3)
  meal_resident_costs = SUM of meal.unit_cost * multiplier (for meals in reconciliation 3)
  guest_costs         = SUM of meal.unit_cost * guest.multiplier (for meals in reconciliation 3)
```

### 2.3 Counter Culture Fields

These fields are automatically maintained by the `counter_culture` gem:

| Model | Field | Source | Delta Column |
|-------|-------|--------|--------------|
| Meal | `bills_count` | Bill count | - |
| Meal | `cost` | Bill sum | `amount_cents` |
| Meal | `meal_residents_count` | MealResident count | - |
| Meal | `meal_residents_multiplier` | MealResident sum | `multiplier` |
| Meal | `guests_count` | Guest count | - |
| Meal | `guests_multiplier` | Guest sum | `multiplier` |
| Resident | `bills_count` | Bill count | - |
| Resident | `bill_costs` | Bill sum | `amount_cents` |
| Unit | `residents_count` | Resident count | - |

---

## 3. Identified Bugs and Issues

### BUG 1: Hard-coded `reconciliation_id == 3` (CRITICAL - Balance Broken)

**Files affected:**
- `app/models/resident.rb:108-133` (bill_reimbursements, meal_resident_costs, guest_costs, calc_balance)
- `app/models/unit.rb:30-41` (balance, meals_cooked)
- `app/controllers/api/v1/meals_controller.rb:129` (update_bills guard)

**Problem:** All balance calculations are hardcoded to only look at meals with `reconciliation_id == 3`. The commented-out code shows the original intent was to use the `unreconciled` scope (`reconciliation_id: nil`). This means:
- If reconciliation 3 doesn't exist, all balances return 0
- If the community creates reconciliation 4, 5, etc., those meals are invisible to balance calculations
- The system can never move past "reconciliation 3"

**The commented-out code** (using `unreconciled` scope) was likely the original approach, but it has its own problem: once meals are reconciled (assigned a reconciliation_id), they disappear from the balance calculation. This means balances reset after each reconciliation, which is probably intentional but needs to be explicit.

### BUG 2: Reimbursement Exceeds Actual Cost (CRITICAL - Trust Issue)

**File:** `app/models/bill.rb:61-69`

```ruby
def reimburseable_amount
  return 0 if amount_cents == 0
  return 0 if multiplier == 0
  value = max_amount
  until value % multiplier == 0 do
    value += 1
  end
  value
end
```

**Problem:** This rounds the cook's cost UP to be divisible by the meal's total multiplier. Examples:

| Cook Spent | Meal Multiplier | Reimbursed | Overpayment |
|-----------|----------------|------------|-------------|
| $50.00 (5000) | 7 | $50.05 (5005) | +$0.05 |
| $50.00 (5000) | 11 | $50.05 (5005) | +$0.05 |
| $50.00 (5000) | 23 | $50.14 (5014) | +$0.14 |
| $75.00 (7500) | 13 | $75.01 (7501) | +$0.01 |

**Why it was done this way:** To ensure `unit_cost` (integer division: `reimburseable_amount / multiplier`) produces a whole number of cents, so that `unit_cost * multiplier` exactly equals `reimburseable_amount`. This avoids pennies getting "lost" in integer division.

**The user's requirement:** "We ought to only ever reimburse exactly what a resident cook indicated their actual cost was." This means we need a different approach to handle the remainder from division.

### BUG 3: Counter Culture Values Drift Over Time (CRITICAL - Data Integrity)

**Problem:** The `counter_culture` gem maintains denormalized sums/counts that can drift from actual values. Known causes:
- Partial transaction failures
- Race conditions with concurrent updates
- Direct database modifications (admin panel, console, migrations)
- Bugs in counter_culture when records are *updated* (not just created/destroyed)

**Fields at risk:**
- `meal.cost` (sum of bill amounts) - affects unit_cost calculations
- `meal.meal_residents_multiplier` / `meal.guests_multiplier` - affects all cost splitting
- `resident.bill_costs` / `resident.bills_count` - not currently used in balance calc but misleading

**Impact:** If `meal.cost` drifts, `bill.max_amount` (which uses `meal.cost`) produces wrong results for capped meals. If multiplier sums drift, every cost calculation for that meal is wrong.

### BUG 4: `no_cost` Bills Not Properly Handled

**File:** `app/models/bill.rb`

**Problem:** The `no_cost` boolean field exists but is never checked in cost calculations. If a bill has `no_cost: true` but `amount_cents: 0`, it works incidentally. But the semantics are unclear - does `no_cost` mean "this cook volunteered but spent nothing" or "don't charge attendees for this bill"?

### BUG 5: Existing Test Passes for Wrong Reason

**File:** `spec/models/resident_spec.rb`

```ruby
it 'has the correct balance' do
  # Creates community, meal, resident, meal_resident, bill
  # Does NOT set reconciliation_id on the meal
  expect(resident.balance).to eq(0)
end
```

**Problem:** This test passes because `calc_balance` returns 0 early (no meals with `reconciliation_id == 3`), not because the balance calculation is correct. The test doesn't actually test balance logic.

### BUG 6: Meal.collected Can Exceed Actual Cost

**File:** `app/models/meal.rb:143-145`

```ruby
def collected
  unit_cost * multiplier
end
```

Because `reimburseable_amount` rounds up, `collected` (what's charged to all attendees combined) can exceed the actual meal cost. The surplus comes from thin air. Over many meals, these phantom pennies accumulate.

### BUG 7: Multiple Bills Per Meal - Rounding Compounds

When a meal has 2+ cooks, each bill independently rounds up its `reimburseable_amount`. The overcharge compounds:

Example: Meal with multiplier 7, two cooks:
- Cook A: $30.00 (3000) -> reimburseable: 3003 (+3 cents)
- Cook B: $20.00 (2000) -> reimburseable: 2002 (+2 cents)
- Total charged to attendees: 5005, but actual cost was 5000 (+5 cents overpaid)

### BUG 8: `meals_attended` Uses Different Scope Than Balance

**File:** `app/models/resident.rb:145-148`

```ruby
def meals_attended
  return 0 if Meal.where(community_id: community_id).unreconciled.count == 0
  meal_residents.joins(:meal).where({:meals => {:reconciliation_id => nil}}).count
end
```

This uses `reconciliation_id: nil` (unreconciled), while balance methods use `reconciliation_id: 3`. These two views of the data are inconsistent.

### BUG 9: Reconciliation Creation is Manual and Incomplete

**File:** `app/models/reconciliation.rb:26-38`

The `update_meals` callback that would auto-assign unreconciled meals to a new reconciliation is commented out. There's no automated path to:
1. Create a new reconciliation
2. Assign the right meals to it
3. Trigger balance calculations
4. Prevent further cost changes on reconciled meals

### ISSUE 10: Integer Cents Loses Precision in Division

All money is stored as integer cents. When splitting $50.01 (5001 cents) among 7 multiplier units:
- `5001 / 7 = 714` (integer division, remainder 3)
- `714 * 7 = 4998` (3 cents less than actual cost)

The current rounding-up approach "solves" this by inflating the amount, but as noted above, that creates its own problem. A better approach would store the remainder explicitly or use fractional cents.

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

## 5. Proposed Remediation Plan

### Phase 1: Fix Hard-coded Reconciliation Scope (High Impact, Low Risk)

**Goal:** Balance calculations work for any reconciliation state, not just `reconciliation_id == 3`.

**Changes:**
1. Replace `reconciliation_id == 3` with dynamic scope: use unreconciled meals (reconciliation_id IS NULL) for the "current period" balance
2. Update `MealsController#update_bills` guard to use `reconciliation_id.present?` instead of `<= 3`
3. Fix the resident balance test to actually test balance logic
4. Add tests for balance calculation with various reconciliation states

**Files:** `resident.rb`, `unit.rb`, `meals_controller.rb`, `resident_spec.rb`

### Phase 2: Migrate to DECIMAL Precision (High Impact, Medium Risk)

**Goal:** All financial columns use `DECIMAL(12, 8)`. All Ruby math uses `BigDecimal`. Cooks are reimbursed exactly what they spent. No phantom money.

**Changes:**
1. Add migration: change `bills.amount_cents` from integer to `DECIMAL(12, 8)`, rename to `amount` (store in dollars, not cents)
   - Or: keep cents-based naming but use DECIMAL. **Recommendation:** switch to dollars — it's less error-prone. Everyone thinks in dollars.
2. Change `meals.cost` and `meals.cap` from integer to `DECIMAL(12, 8)`
3. Change `resident_balances.amount` from integer to `DECIMAL(12, 8)`
4. Remove `reimburseable_amount` round-up logic entirely. Cook reimbursement = `amount` (their actual cost).
5. `bill.unit_cost` = `amount / meal.multiplier` (BigDecimal division, full precision)
6. `MealResident#cost` and `Guest#cost` use BigDecimal multiplication
7. Balance calculations sum BigDecimal values at full precision
8. Remove `money-rails` gem (it assumes integer cents, conflicts with DECIMAL approach)
9. Add a `Monetizable` concern or helper for formatting: `number_to_currency` for display
10. At reconciliation time: round each resident's balance to cents using `BigDecimal::ROUND_HALF_EVEN`

### Phase 3: Remove Counter Culture from Financial Fields (Medium Impact, Medium Risk)

**Goal:** Eliminate drift. Financial data always calculated from source of truth.

**Changes:**
1. Remove counter_culture declarations for financial fields (keep count fields if desired for display)
2. Create a rake task `billing:recalculate` that:
   - For each meal: recalculates cost from bills, multiplier sums from attendees
   - For each resident: recalculates balance from bills and attendance
   - Stores results in `resident_balances` table
3. Schedule rake task to run daily
4. Meal model methods (`unit_cost`, `modified_cost`, `collected`) compute from associations (they already do this for some)
5. Remove or repurpose `meal.cost` column (or keep it but populate it from the rake task)

**Counter culture fields to remove:**
- `meal.cost` — replace with `bills.sum(:amount)` computed by rake task or on read
- `resident.bill_costs` — not used in balance calc, remove entirely
- `resident.bills_count` — informational only, can be queried

**Counter culture fields to keep (non-financial, verified by rake task):**
- `meal.bills_count` — display only, not used in financial math
- `meal.meal_residents_count`, `meal.guests_count` — attendance display
- `meal.meal_residents_multiplier`, `meal.guests_multiplier` — **critical for cost splitting**; keep counter_culture but verify/correct in daily rake task
- `unit.residents_count` — non-financial

**On multiplier sums:** These are used as the divisor in cost splitting, so correctness is essential. Strategy: keep counter_culture for responsiveness (the UI needs to show "N attendees" immediately), but the daily rake task re-derives and overwrites them from source records. If they drifted, the rake task fixes them. Financial calculations in the rake task always compute from source, never trust the cached column.

### Phase 4: Automate Reconciliation Lifecycle (Medium Impact, Low Risk)

**Goal:** Clear, repeatable process for reconciling a billing period.

**Changes:**
1. Un-comment and fix `Reconciliation#update_meals` to auto-assign unreconciled meals with bills
2. Add a rake task or admin action: `reconciliations:create` that:
   - Creates a new Reconciliation record
   - Assigns all unreconciled meals (with at least one bill) to it
   - Triggers balance recalculation
   - Sends notification emails to cooks
3. Add guard: reconciled meals cannot have bills modified (already partially exists)
4. Decouple from rotations: remove any implicit assumption that reconciliation boundaries align with rotation boundaries

### Phase 5: Test Coverage (Ongoing, Throughout)

Write tests for each phase as we go. Priority test scenarios:

1. **Basic cost splitting:** 1 cook, N attendees, verify each attendee's cost
2. **Multi-cook splitting:** 2 cooks with different amounts, verify reimbursement and attendee costs
3. **Child/adult mix:** Attendees with different multipliers, verify proportional costs
4. **Guests:** Resident brings guest, verify guest cost charged to host
5. **Capped meals:** Community cap applied, verify bill max_amount and unit_cost
6. **Subsidized meals:** Cost exceeds cap, verify subsidy calculation
7. **Balance across multiple meals:** Resident cooks one meal, attends another, verify balance
8. **Reconciliation lifecycle:** Create reconciliation, verify meals assigned, verify balance resets
9. **Zero-cost meals:** Bill with no_cost or amount=0
10. **Edge cases:** Meal with 0 attendees, meal with only children, etc.

### Phase 6: Frontend Compatibility

Each backend change needs corresponding frontend updates in `comeals-ui`:

| Backend Change | Frontend Impact |
|---------------|----------------|
| Balance scope fix | Balance display may show different numbers - verify |
| Reimbursement change | Bill display in admin and cooks_box.jsx may show different "reimburseable" values |
| Counter culture removal | API responses may be slower if computed on the fly (or unchanged if using cached/rake values) |
| Reconciliation automation | May need UI for triggering reconciliation |

---

## 6. Phased Implementation Order

```
Phase 1 (Fix hard-coded scope)     <- DO FIRST, highest impact, lowest risk
  |
Phase 5 (Tests for Phase 1)        <- Validate the fix
  |
Phase 2 (Fix reimbursement)        <- Requires design decision, high impact
  |
Phase 5 (Tests for Phase 2)
  |
Phase 3 (Remove counter_culture)   <- Biggest structural change
  |
Phase 5 (Tests for Phase 3)
  |
Phase 4 (Reconciliation lifecycle) <- Builds on Phase 1 + 3
  |
Phase 6 (Frontend updates)         <- After backend is stable
```

---

## 7. Environment

- **Ruby:** 3.2.10 (latest 3.2 patch). Long-term plan: upgrade to Ruby 4.
- **Database:** PostgreSQL
- **Tests:** `bundle exec rspec` — 3 real tests, 6 pending stubs. Test database: `comeals_test`.

---

## 8. Open Questions

1. **How often does the community reconcile?** (Every N meals? Monthly? Quarterly?)
2. **What is the community's cost cap currently set to?** (Is the cap feature actively used?)
3. **Are there residents with multiplier values other than 1 or 2?** (The admin UI hints at custom multipliers)
4. **Decision 6:** Is the cap per-adult-unit or per-multiplier-unit?
5. **What should `no_cost` mean?** "Cook volunteered, spent nothing" or "don't charge attendees for this cook's portion"?

---

## 9. Key Files Reference

### Financial Logic (the code that needs fixing)
- `app/models/bill.rb` — reimburseable_amount, unit_cost, max_amount
- `app/models/meal.rb` — multiplier, unit_cost, modified_cost, collected, max_cost
- `app/models/resident.rb` — bill_reimbursements, meal_resident_costs, guest_costs, calc_balance, balance
- `app/models/meal_resident.rb` — cost
- `app/models/guest.rb` — cost
- `app/models/unit.rb` — balance, meals_cooked
- `app/models/reconciliation.rb` — update_meals (commented out)
- `app/controllers/api/v1/meals_controller.rb` — update_bills

### Tests
- `spec/models/bill_spec.rb` — 2 tests
- `spec/models/resident_spec.rb` — 1 test (passes for wrong reason)

### Admin
- `app/admin/bill.rb`, `app/admin/meal.rb`, `app/admin/resident.rb`

### Frontend (../comeals-ui)
- `src/stores/bill.js` — bill model, amountCents conversion
- `src/stores/data_store.js` — submitBills, loadDataAsync
- `src/components/meal/cooks_box.jsx` — bill entry UI
