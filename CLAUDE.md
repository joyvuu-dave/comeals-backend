# CLAUDE.md - Comeals Backend

## Project Overview

Comeals is a meal management and cost-splitting application for a co-housing community. Residents sign up for communal dinners, volunteer to cook, and the cost is split proportionally among attendees. The system tracks attendance, cooking costs, and financial balances across billing periods (reconciliations).

This is a Rails 7 API backend. The frontend lives at `../comeals-ui` (React/MobX).

## Development Environment

```bash
# Ruby version managed by rbenv (see .ruby-version)
# PostgreSQL database
# Run tests: bundle exec rspec
# Run server: bundle exec rails s
# Rails console: bundle exec rails c
```

### Local URLs

- **Rails API**: `http://localhost:3000`
- **Admin console**: `http://admin.lvh.me:3000/login` (ActiveAdmin, uses subdomain routing via `lvh.me` which resolves to 127.0.0.1)
- **Frontend (comeals-ui)**: `http://localhost:3001` (dev: `npm start` from `../comeals-ui`; production-like: `npm run build && node server.js`; requires Node 22+)

## Collaboration Style

**Be an opinionated pair programmer.** This is a personal project with one developer. There is no committee to appease. Push back on design choices that are wrong. Propose alternatives when something smells off. Don't hedge with "you could do X or Y" — say which one is right and why.

**Be rigorous.** This codebase should be a textbook example of correct software. No shortcuts. No "good enough for now." If there's a standard way to do something (an RFC, a well-known pattern, a financial industry convention), follow it.

**Err on the side of correctness over convenience.** A slow correct answer beats a fast wrong one. An explicit verbose approach beats a clever implicit one.

## Money Handling Standards

This is the most critical section. Financial calculations in this codebase must meet the same standards a bank or accounting system would use.

### Rules

1. **Never use Float for money.** Not in Ruby, not in SQL, not anywhere. Use `BigDecimal` in Ruby and `NUMERIC`/`DECIMAL` in PostgreSQL. Float arithmetic produces rounding errors (e.g., `0.1 + 0.2 != 0.3`). This is not acceptable for money.

2. **Store monetary values as DECIMAL(12, 8) in the database.** 8 decimal places beyond the dollar. This gives sub-micro-cent precision for intermediate calculations. The only exception is user-input amounts (what a cook spent), which are whole cents — but even those should be stored in DECIMAL columns for type consistency.

3. **Use BigDecimal for all arithmetic in Ruby.** When reading from the database, ensure values are BigDecimal, not Float. When dividing, use `BigDecimal` division with explicit scale: `amount / divisor` where both are BigDecimal.

4. **Round to cents only at settlement/reconciliation time.** During the billing period, all intermediate values (per-unit costs, individual charges, running balances) remain at full precision. Only when generating the final "you owe $X.XX" do we round.

5. **Use banker's rounding** (round half to even, `BigDecimal::ROUND_HALF_EVEN`) for the final cent rounding. This is the standard in finance and accounting (IEEE 754). It eliminates the bias of always rounding 0.5 up.

6. **Balances are always derived, never stored as source of truth.** The source of truth is the set of bills + attendance records. Balances are materialized views — computed from source data by a daily rake task. If the balance table is wiped, it can be perfectly reconstructed.

7. **Financial records are append-only / immutable where possible.** Once a meal is reconciled, its bills and attendance cannot change. This is an accounting principle: you don't edit the ledger, you add correcting entries.

8. **No denormalized counters or caches for financial data.** The `counter_culture` gem has been removed entirely. All derived values (costs, counts, multiplier sums) are computed from source data via SQL queries or Ruby enumeration. The only cache is `resident_balances`, refreshed daily by the rake task.

9. **Prevent race conditions by design.** The daily balance computation is a batch job that reads immutable source data and writes results. There's no concurrent write contention. For real-time operations (adding attendees, submitting bills), use database transactions.

10. **All money-related code must have tests.** Every calculation path, every edge case (zero attendees, single attendee, child-only meals, multi-cook meals, capped meals, etc.) must be covered.

### The Money Model

```
INPUT (cook's receipt):     Dollars — $50.00 stored as 50.00000000
                            (User enters whole dollars/cents; stored as DECIMAL(12,8))

INTERMEDIATE (per-unit):    Full precision DECIMAL
                            e.g., 50.00 / 7 = 7.14285714...

STORED (charges/credits):   Full precision DECIMAL(12,8)
                            Each resident's charge for each meal stored at full precision

SETTLEMENT (reconciliation): Rounded to cents using banker's rounding
                             The final "you owe $X.XX" or "you are owed $X.XX"
```

## Code Standards

- **No FIXME/TODO hacks in financial code.** If something needs to change, change it or create a tracked issue.
- **No hardcoded IDs.** All queries must use proper scopes (e.g., `Meal.unreconciled`), never hardcoded record IDs.
- **Explicit over implicit.** Name things clearly. `bill.amount` is the cook's actual cost. `bill.effective_amount` accounts for `no_cost` flag.
- **Test edge cases.** Zero multiplier, zero cost, single attendee, no attendees, meal with only children, meal with only guests, etc.
- **Database constraints.** Use NOT NULL, CHECK constraints, and foreign keys. Don't rely on Rails validations alone — the database is the last line of defense.

## Architecture Decisions

- **Reconciliations are billing periods, Rotations are cooking schedules.** These are fully decoupled. A reconciliation can span multiple rotations.
- **Balances computed daily via rake task.** Not real-time. This eliminates drift and race conditions.
- **The `resident_balances` table is a cache.** It can be rebuilt from source data at any time.
- **Frontend compatibility is required.** Every backend change must consider impact on `../comeals-ui`. API response shapes should not change without updating the frontend.

## Current State

The billing system remediation is complete and validated against production data. See `BILLING_ANALYSIS.md` for the full bug list and history. What was done:

- Fixed hardcoded `reconciliation_id == 3` → uses `Meal.unreconciled` scope
- Migrated to `DECIMAL(12,8)` + `BigDecimal`, removed `money-rails`, removed reimbursement rounding
- Removed `counter_culture` gem entirely — all derived values computed from source data
- Automated reconciliation lifecycle with `assign_meals` + `settlement_balances` (banker's rounding)
- Added input validation for malformed bill amounts in `update_bills` controller action
- Fixed `set_meal` before_action to properly return on 404 instead of crashing

**Rake tasks:**
- `rake billing:recalculate` — run daily to refresh resident balances from source data
- `rake reconciliations:create` — manual trigger to close a billing period

**Test coverage:** 138 tests (124 model + 14 request specs), 0 failures.
