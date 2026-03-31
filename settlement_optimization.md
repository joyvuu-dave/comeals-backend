# Debt Settlement Optimization: Implementation Instructions

## What We're Building

We need a **debt settlement optimization service** for a common meals billing system. After a billing period closes, each participant has a single **net balance**: positive (they are a **creditor** — owed money) or negative (they are a **debtor** — they owe money). The sum of all net balances is zero by definition.

The goal is to compute a minimal set of peer-to-peer transfers that zeroes out all balances.

## The Graph Theory Problem

This is a variant of the **minimum-transaction debt settlement problem**. Given a set of participants with net balances summing to zero, find a set of directed transfers (debtor → creditor) that settles all debts.

### Standard Objective (not what we want)

The standard formulation minimizes the **total number of transactions**. The naive greedy approach (match largest debtor to largest creditor, settle, repeat) yields at most **n − 1** transactions where *n* is the number of participants with non-zero balances. The true optimum is **n − k**, where *k* is the maximum number of groups the participants can be partitioned into such that each group's balances independently sum to zero. Finding optimal *k* is NP-hard in general (reduces to subset-sum), but is tractable for small *n* via bitmask dynamic programming.

### Our Objective: Minimax Degree

We want to minimize the **maximum number of transactions any single person is involved in**. This is a **minimax degree** (or **bottleneck degree**) objective on the settlement graph.

In other words: if person A makes 2 payments and receives 0, their degree is 2. If person B makes 0 payments and receives 4, their degree is 4. We want to minimize the largest such degree across all participants.

This is distinct from minimizing total transaction count. A solution with 12 total transactions where no one does more than 2 is preferable to a solution with 10 total transactions where one person does 5.

## Algorithm Approach

Given the expected scale (15–40 participants per community, typically 8–20 with non-zero balances), we can afford exact or near-exact methods. Here is the recommended approach:

### Step 1: Compute Net Balances

From the billing period's meal records, compute each participant's single net balance (total they're owed minus total they owe). Discard anyone with a zero balance. You should be left with a set of debtors (negative balances) and creditors (positive balances).

### Step 2: Binary Search on Maximum Degree

Binary search on the answer *d* (the maximum degree). For each candidate *d*, ask: "Can all debts be settled such that no participant is involved in more than *d* transactions?"

The lower bound for *d* is `ceil(max_imbalance)` where `max_imbalance` is:
- For each creditor: how many debtors must they receive from at minimum? (Their credit divided by the largest single debt, rounded up — though this is a loose bound.)
- More practically, the lower bound is `max(ceil(total_debt / (d * max_single_debt)), 1)` but the simplest correct lower bound is **1** and the upper bound is `max(number_of_debtors, number_of_creditors)`.

A cleaner framing: binary search *d* from 1 to n−1. For each *d*, test feasibility.

### Step 3: Feasibility Check for a Given Max Degree *d*

For a given *d*, the feasibility question is: can we construct a bipartite graph between debtors and creditors such that:
- Each debtor node has out-degree ≤ *d*
- Each creditor node has in-degree ≤ *d*
- The flow on each edge is > 0
- Each debtor's outflows sum to exactly their debt
- Each creditor's inflows sum to exactly their credit

This is a **capacitated bipartite flow problem**. Model it as a max-flow / min-cost-flow problem:
- Source → each debtor with capacity = their debt amount
- Each debtor → each creditor with capacity = min(debtor's debt, creditor's credit) — but limit each debtor to at most *d* outgoing edges, and each creditor to at most *d* incoming edges
- Each creditor → sink with capacity = their credit amount

The degree constraint makes this trickier than standard flow. One practical approach for the feasibility check at this scale:

**Greedy with backtracking or constraint propagation:**
1. Sort debtors and creditors by magnitude (descending).
2. For each debtor, try to settle their balance using at most *d* creditors, largest-first.
3. If any debtor cannot be settled within *d* transfers, the degree *d* is infeasible.
4. Also verify no creditor exceeds *d* incoming transfers.

**Alternative — ILP formulation (perfectly tractable at this scale):**
Use a small integer linear program. Decision variables:
- `x[i][j]` = amount debtor *i* pays creditor *j* (continuous, ≥ 0)
- `y[i][j]` = 1 if `x[i][j] > 0`, 0 otherwise (binary)

Constraints:
- For each debtor *i*: `sum_j(x[i][j]) = debt[i]`
- For each creditor *j*: `sum_i(x[i][j]) = credit[j]`
- Linking: `x[i][j] ≤ M * y[i][j]` (where M is a large constant, e.g., the total debt pool)
- Degree: `sum_j(y[i][j]) ≤ d` for each debtor *i*
- Degree: `sum_i(y[i][j]) ≤ d` for each creditor *j*

Minimize *d* (or binary search on *d* and test feasibility).

At n ≤ 40, this ILP has at most ~400 binary variables — any solver handles this in milliseconds.

**Recommended Ruby libraries for ILP:** If available, use the `cbc` gem (wraps COIN-OR CBC solver) or shell out to `glpsol` (GLPK). If adding a solver dependency is undesirable, the greedy approach with binary search will produce good (often optimal) results at this scale.

### Step 4: Extract the Transaction List

Once you've found the minimum feasible *d* and a corresponding assignment, extract the set of transfers: `[(debtor, creditor, amount), ...]`.

### Step 5: Round to Currency Precision

All amounts should be rounded to the cent. Handle rounding carefully — ensure balances still net to zero after rounding. A simple approach: round all but the last transfer for each participant, and let the last transfer absorb any rounding residual.

## Data Model Suggestions

You'll likely want something like:

```ruby
# A new model or service object — something like:

class SettlementPlan
  # Belongs to a billing period / reconciliation cycle
  # Has many settlement_transfers
end

class SettlementTransfer
  # belongs_to :settlement_plan
  # belongs_to :debtor, class_name: 'User' (or however participants are modeled)
  # belongs_to :creditor, class_name: 'User'
  # amount: decimal
  # status: enum (pending, confirmed_by_debtor, confirmed_by_creditor, completed, disputed)
end
```

The `status` field is important. Since money moves outside the app (via Venmo, Zelle, bank transfer, etc.), both parties should be able to confirm that a transfer occurred. Consider requiring confirmation from at least the creditor (the person who should have received money).

## Integration Notes

- This should be a **service object** (e.g., `SettlementOptimizer`) that takes a set of `(participant_id, net_balance)` pairs and returns a set of `(debtor_id, creditor_id, amount)` tuples.
- The optimizer should be invoked when an admin or the community "finalizes" a billing period.
- Net balances should be computed from the existing meal cost and attendance records — the optimizer does not need to know about individual meals, only final net positions.
- All arithmetic should use `BigDecimal` or integer cents to avoid floating-point errors.
- Include a validation that `sum(all_net_balances) == 0` before running the optimizer. If it doesn't (due to rounding in upstream calculations), adjust the smallest balance to force equilibrium.

## Edge Cases

- **Only one debtor or one creditor:** Degenerate but valid. One person pays everyone or everyone pays one person. The max degree equals the number of counterparties.
- **Two people with exactly offsetting balances:** Single transfer.
- **Very unequal magnitudes:** One person cooked 30 meals and is owed $1,500 while 15 people each owe $100. The minimum max degree might be forced high for that one creditor. The algorithm should still minimize it globally.
- **Tiny residual balances:** Consider a threshold (e.g., < $0.50) below which balances are zeroed out and forgiven, to avoid creating transactions for trivial amounts. Make this configurable per community.

## What Success Looks Like

Given a realistic scenario of ~25 participants where ~10 are debtors and ~5 are creditors:
- The naive approach might have one popular cook receiving 10 separate payments.
- The greedy n−1 approach produces ~14 transactions, possibly with one person involved in 5+.
- **Our optimizer should produce a plan where no individual is involved in more than 2–3 transactions**, even if the total transaction count is slightly higher.

The output should be a human-readable settlement plan, e.g.:

```
Settlement Plan for March 2026
================================
Alice pays Bob: $47.25
Alice pays Carol: $31.50
Dave pays Carol: $62.00
Dave pays Eve: $18.75
Frank pays Bob: $55.00
...

Maximum transactions per person: 2
Total transactions: 8
```