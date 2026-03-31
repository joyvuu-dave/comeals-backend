# Settlement Optimizer Implementation Plan

## Context

After a reconciliation closes, each resident has a net balance (positive = creditor, negative = debtor). Currently we store these balances but don't compute how people should actually pay each other. This feature adds an optimal debt settlement service that minimizes the **maximum number of transactions any single person is involved in** (minimax degree), using a MILP solver for provably optimal results.

No rounding tolerance, no de minimis forgiveness. Exact, mathematically perfect settlement.

## Gems

```ruby
gem 'opt-rb'   # algebraic MILP modeling (pure Ruby, 15KB)
gem 'highs'    # HiGHS solver, bundles native binary (~8.7MB), no system dependency
```

`opt-rb` provides `Opt::Variable`, `Opt::Binary`, `Opt::Integer`, `Opt::Problem` with operator overloading. `highs` bundles the HiGHS solver library (no `apt install` / `brew install` needed — works on Heroku out of the box).

## MILP Formulation

Given m debtors with debts a[i] and n creditors with credits b[j], all in **integer cents**:

**Variables:**
- `x[i][j]` >= 0 (continuous): cents debtor i pays creditor j
- `y[i][j]` in {0,1} (binary): whether that transfer exists
- `d` in {1..max(m,n)} (integer): the maximum degree to minimize

**Constraints:**
- Debtor flow: `sum_j(x[i][j]) == a[i]` for each debtor i
- Creditor flow: `sum_i(x[i][j]) == b[j]` for each creditor j
- Linking: `x[i][j] <= min(a[i], b[j]) * y[i][j]` (tight big-M)
- Debtor degree: `sum_j(y[i][j]) <= d` for each debtor i
- Creditor degree: `sum_i(y[i][j]) <= d` for each creditor j

**Objective:** `minimize d * (m*n + 1) + sum(y[i][j])`

The weight `(m*n + 1)` gives **lexicographic optimization in a single solve**: minimize max degree first, then minimize total transaction count as a tiebreaker. Since total edges <= m*n, reducing d by 1 always dominates any number of extra edges.

## Currency Precision Strategy

1. Input balances are BigDecimal rounded to cents (from `settlement_balances`)
2. Multiply by 100, convert to Integer — exact because input is already at 2 decimal places
3. Force zero-sum: if rounding left a sub-cent imbalance, adjust the largest-magnitude balance by the residual (at most a few cents)
4. Pass integers to solver as Float (exact for integers up to 2^53)
5. Read solution: round each x[i][j] to nearest integer (solver tolerance ~1e-6 means this is exact)
6. **Reconcile rounding per participant**: for each debtor, set all-but-last transfer to rounded value, last transfer = remaining cents. Same for creditors if needed.
7. Convert back: `BigDecimal(cents) / BigDecimal('100')`

## Service Object

**File:** `app/services/settlement_optimizer.rb`

```ruby
class SettlementOptimizer
  Transfer = Data.define(:debtor_id, :creditor_id, :amount)
  Result = Data.define(:transfers, :max_degree, :total_transactions)

  def self.call(balances) = new(balances).call
```

**Public interface:** `SettlementOptimizer.call({ resident_id => BigDecimal })` returns a `Result`.

**Internal flow:**
1. `validate_balances!` — sum within tolerance, raise `ImbalancedError` if not
2. Filter zero balances, return empty result if nothing to settle
3. `partition_balances` — split into debtors (negate to positive) and creditors
4. Short-circuit trivial cases (1 debtor or 1 creditor) without invoking solver
5. `to_cents` — convert to integer cents, force zero-sum
6. `solve_milp` — build and solve the MILP via opt-rb/highs
7. `round_and_reconcile` — convert solution back to exact BigDecimal cents
8. Return `Result` with transfers, max_degree, total_transactions

**Error classes:** `SettlementOptimizer::ImbalancedError`, `SettlementOptimizer::InfeasibleError`

## Data Model

### Migration 1: `create_settlement_plans`

```
settlement_plans
  id             bigint PK
  reconciliation_id  bigint NOT NULL, FK, UNIQUE
  max_degree     integer NOT NULL
  total_transactions integer NOT NULL
  generated_at   datetime NOT NULL
  timestamps
```

One plan per reconciliation (unique constraint). Immutable financial record.

### Migration 2: `create_settlement_transfers`

```
settlement_transfers
  id                 bigint PK
  settlement_plan_id bigint NOT NULL, FK
  debtor_id          bigint NOT NULL, FK -> residents
  creditor_id        bigint NOT NULL, FK -> residents
  amount             decimal(12,8) NOT NULL, CHECK > 0
  timestamps
```

### Models

- `SettlementPlan`: belongs_to :reconciliation, has_many :settlement_transfers
- `SettlementTransfer`: belongs_to :settlement_plan, belongs_to :debtor (Resident), belongs_to :creditor (Resident)

### Association changes to existing models

- `Reconciliation`: add `has_one :settlement_plan, dependent: :destroy`
- `Resident`: add `has_many :settlement_transfers_as_debtor` and `has_many :settlement_transfers_as_creditor`

## Integration

**On-demand, not in the `finalize` callback.** The settlement plan is a downstream artifact. If the solver fails, it should not roll back the reconciliation.

Add `Reconciliation#generate_settlement_plan!`:
- Reads persisted `reconciliation_balances`
- Calls `SettlementOptimizer.call`
- Persists `SettlementPlan` + `SettlementTransfers`
- Idempotent: destroys existing plan before regenerating

Invoke from `reconciliations:create` rake task, after reconciliation creation, outside the creation transaction.

## Test Strategy

**File:** `spec/services/settlement_optimizer_spec.rb`

Tests use raw integer IDs as balance keys — no database needed, fast and isolated.

| Group | Tests |
|-------|-------|
| **Validation** | ImbalancedError on bad sum; accepts sub-cent discrepancy; empty/all-zero input |
| **Trivial cases** | Empty -> 0 transfers; 1v1 -> 1 transfer; 1vN -> N transfers (d=N); Nv1 -> N transfers (d=N) |
| **Known-optimal** | Symmetric 2x2 (d=1); Asymmetric 3x2 (d=2); 1 creditor + 10 debtors (d=10); large community 8v4 scenario |
| **Flow conservation** | Every test verifies: debtor outflows == debt, creditor inflows == credit, all amounts positive, all amounts BigDecimal |
| **Optimality proofs** | Analytical lower bounds documented in test comments (e.g., ceil(credit/max_single_debt) forces minimum degree) |
| **Rounding** | Balances producing non-integer cent solver values; verify exact cent output |

**Model specs:** `spec/models/settlement_plan_spec.rb`, `spec/models/settlement_transfer_spec.rb` — validations, associations, uniqueness constraints.

**Integration spec** in `spec/models/reconciliation_spec.rb`: create reconciliation with known balances, call `generate_settlement_plan!`, verify plan correctness.

## Files

### New files
| File | Purpose |
|------|---------|
| `app/services/settlement_optimizer.rb` | Core MILP optimizer |
| `app/models/settlement_plan.rb` | Plan model |
| `app/models/settlement_transfer.rb` | Transfer model |
| `db/migrate/..._create_settlement_plans.rb` | Migration |
| `db/migrate/..._create_settlement_transfers.rb` | Migration |
| `spec/services/settlement_optimizer_spec.rb` | Optimizer tests |
| `spec/models/settlement_plan_spec.rb` | Model tests |
| `spec/models/settlement_transfer_spec.rb` | Model tests |
| `spec/factories/settlement_plans.rb` | Factory |
| `spec/factories/settlement_transfers.rb` | Factory |

### Modified files
| File | Change |
|------|--------|
| `Gemfile` | Add `opt-rb`, `highs` |
| `app/models/reconciliation.rb` | Add `has_one :settlement_plan`, `generate_settlement_plan!` |
| `app/models/resident.rb` | Add settlement transfer associations |
| `lib/tasks/reconciliations/create.rake` | Call `generate_settlement_plan!` after creation |

## Implementation Sequence

**Phase 1 — Gems + pure optimizer (no DB):**
1. Add gems to Gemfile, bundle install
2. Create `app/services/` directory
3. Implement `SettlementOptimizer`
4. Write optimizer specs, verify all pass

**Phase 2 — Data model:**
5. Create migrations
6. Run migrations
7. Create models with validations/associations
8. Create factories
9. Write model specs

**Phase 3 — Integration:**
10. Add associations to Reconciliation and Resident
11. Implement `generate_settlement_plan!`
12. Add to rake task
13. Write integration test

## Verification

```bash
bundle exec rspec spec/services/settlement_optimizer_spec.rb
bundle exec rspec spec/models/settlement_plan_spec.rb spec/models/settlement_transfer_spec.rb
bundle exec rspec spec/models/reconciliation_spec.rb
bundle exec rspec  # full suite — all 138+ existing tests still pass
```
