# Pre-Production Deploy Checklist

This document tracks everything that must be addressed or investigated before deploying the `billing-system-remediation` branch to production. Items are ordered by risk level.

---

## CRITICAL — Must resolve before deploy

### 1. Simultaneous frontend + backend deploy required

The API field `amount_cents` (integer) was renamed to `amount` (decimal dollars). If either side deploys without the other, all bill saves will silently write $0.

**Action items:**
- [ ] Plan a coordinated deploy (both repos at once) or a brief maintenance window
- [ ] Alternatively, add temporary backwards compatibility: accept both `amount_cents` and `amount` in the controller, return both in the serializer. Deploy backend first, then frontend, then remove the compat layer.

### 2. Verify production reconciliation data

The old code computed balances from `reconciliation_id == 3`. The new code computes from `reconciliation_id IS NULL` (unreconciled meals only). If the "active" billing period's meals are assigned to reconciliation 3, deploying will immediately exclude them from balance calculations — balances drop to zero.

**Action items:**
- [ ] Run against production DB: `SELECT reconciliation_id, COUNT(*) FROM meals WHERE reconciliation_id IS NOT NULL GROUP BY reconciliation_id ORDER BY reconciliation_id`
- [ ] Run: `SELECT COUNT(*) FROM meals WHERE reconciliation_id IS NULL`
- [ ] Determine: are there unreconciled meals with bills? Or is everything assigned to a reconciliation?
- [ ] If needed: write a one-time data migration to NULL out the reconciliation_id on the "current period" meals so they show as unreconciled under the new code

### 3. Heroku must run `npm install` for admin panel

The admin panel requires `moment.js` from `node_modules/` (loaded via Sprockets asset path). Heroku needs to detect the backend's `package.json` and run `npm install` during slug compilation.

**Action items:**
- [ ] Verify the Heroku buildpack includes Node.js (or add the Node buildpack alongside Ruby)
- [ ] Verify `npm install` runs during deploy and `node_modules/moment/moment.js` is present in the slug
- [ ] Alternative: vendor moment.js directly in `vendor/assets/javascripts/` to remove the npm dependency entirely

### 4. No rollback plan documented

The migration converts integer cents to DECIMAL dollars. The `down` migration reverses this, but any new data entered after deploy (bills in dollars) will be truncated to integer cents on rollback. Sub-cent precision is lost.

**Action items:**
- [ ] Take a database backup before deploying
- [ ] Document the rollback procedure: revert code, run `rails db:rollback STEP=5`, redeploy old code + old frontend
- [ ] Accept that rollback after new data entry may lose fractional cent precision (acceptable since amounts are always whole cents from user input)

---

## HIGH — Should resolve before deploy

### 5. Controller tests for `update_bills`

The most critical API endpoint — where cooks submit bill amounts — has zero test coverage at the HTTP level. A malformed request, missing params, BigDecimal parse error, or auth failure is uncovered.

**Action items:**
- [ ] Write request specs for `PATCH /api/v1/meals/:meal_id/bills`:
  - Successful bill update with valid amounts
  - Rejection when meal is reconciled
  - Handling of `no_cost: true` bills
  - Handling of malformed `amount` param (non-numeric string)
  - Authentication required (401 without token)
  - Authorization required (403 for wrong community)
- [ ] Write request specs for the reconciliation guard on other mutation endpoints

### 6. Update stale documentation

Three docs reference counter_culture and the dropped `meals.cost` column:

**Action items:**
- [ ] Update `BILLING_ANALYSIS.md` — remove counter_culture references, update the "Current Implementation" section to reflect the final architecture
- [ ] Update `MODELS.md` — remove the "Counter Culture Summary" table, update any references to cached columns
- [ ] Update `CLAUDE.md` — remove "No counter_culture for financial fields" (now there's no counter_culture at all)

### 7. Test against a copy of production data

Model-level tests prove the logic is correct with synthetic data. But production data may have edge cases: meals with zero attendees, bills with amount 0, orphaned records, etc.

**Action items:**
- [ ] Pull a production database dump to a staging environment
- [ ] Run all migrations against it
- [ ] Run `rake billing:recalculate` and inspect the output
- [ ] Spot-check balances for a few residents against manual calculations
- [ ] Verify the admin panel loads without errors
- [ ] Verify the frontend loads and displays meals correctly

---

## MEDIUM — Should address soon after deploy

### 8. Integration / request-level tests

All 124 tests are model-level unit tests. The full request cycle (HTTP → controller → model → serializer → JSON response) is untested.

**Action items:**
- [ ] Add request specs for key API endpoints:
  - `GET /api/v1/meals/:id/cooks` (the main meal detail view)
  - `POST /api/v1/meals/:id/residents/:id` (sign up for meal)
  - `DELETE /api/v1/meals/:id/residents/:id` (leave meal)
  - `PATCH /api/v1/meals/:id/bills` (submit cook costs)
  - `PATCH /api/v1/meals/:id/closed` (close meal)
- [ ] Verify serialized JSON matches what the frontend expects

### 9. Mailer tests

`ResidentMailer` has 3 methods (password_reset, rotation_signup, new_rotation) with zero test coverage. `ReconciliationMailer` has 2 methods also untested.

**Action items:**
- [ ] Add specs that verify email subject, recipient, and body content
- [ ] Verify the reconciliation email URL format works with the new admin panel (the URL includes `reconciliation_id` in a query param)

### 10. Frontend tests

The React app (`comeals-ui`) has zero test files. The bill store, data store, and component logic are completely untested.

**Action items:**
- [ ] Add tests for `bill.js` store (amountIsValid with various inputs)
- [ ] Add tests for `data_store.js` (submitBills payload format, loadData parsing)
- [ ] Consider adding React Testing Library for component tests

### 11. Rubocop cleanup on meals_controller

The `update_bills` method in `meals_controller.rb` has ~100 rubocop offenses (deep nesting, long method, old hash syntax). We only changed 2 lines there but the method is fragile.

**Action items:**
- [ ] Refactor `update_bills` into smaller methods
- [ ] Fix hash syntax, string quoting, line length
- [ ] Consider extracting bill update logic into a service object

### 12. ESLint warnings in frontend

16 pre-existing `console.log` warnings in `data_store.js` and `index.js`. Not bugs, but noisy.

**Action items:**
- [ ] Replace `console.log` in error handlers with a proper error reporting pattern (or add `// eslint-disable-next-line no-console` where intentional)

---

## LOW — Nice to have

### 13. Performance: `another_meal_in_this_rotation_has_less_than_two_cooks?`

This method now loads all meals in the rotation into Ruby and calls `bills_count` (a COUNT query) on each, instead of the previous single `pluck(:bills_count)` on the cached column.

**Action items:**
- [ ] Rewrite to use a SQL subquery: `Meal.where(rotation_id: rotation_id).where.not(id: id).where('(SELECT COUNT(*) FROM bills WHERE bills.meal_id = meals.id) < 2').exists?`
- [ ] Or: accept the minor perf hit (rotations have ~12 meals, so it's 12 COUNT queries)

### 14. Admin panel eager loading

Admin index pages listing many meals now fire COUNT/SUM queries per meal for attendee counts and multipliers. With 30 meals per page, this is ~60-90 queries.

**Action items:**
- [ ] Add `includes(:meal_residents, :guests, :bills)` to admin controller scoped_collection methods
- [ ] Or: accept the overhead for admin pages (low traffic, not user-facing)

### 15. Schedule the daily rake task

`rake billing:recalculate` needs to run daily in production.

**Action items:**
- [ ] Add to Heroku Scheduler: `rake billing:recalculate` at 3:00 AM Pacific
- [ ] Or set up a cron job if self-hosted

### 16. Node.js version manager in production/CI

We installed `fnm` locally for development. Production/CI may need Node.js configured.

**Action items:**
- [ ] Add `.node-version` file with `20.11.1` (fnm and other managers read this)
- [ ] Verify CI pipeline has Node.js available (if applicable)

### 17. Dependabot vulnerabilities

GitHub flagged 53 vulnerabilities on the backend and 94 on the frontend. These are pre-existing and not related to our changes, but they're worth addressing.

**Action items:**
- [ ] Run `bundle audit` and `npm audit` to triage
- [ ] Upgrade vulnerable dependencies where feasible
- [ ] Many may be in transitive dependencies of old gems (activeadmin, react-scripts 1.x)

---

## Deployment Sequence (Recommended)

```
1. Take production database backup
2. Pull production DB to staging, run migrations, verify
3. Write one-time data migration if needed (reconciliation_id fix)
4. Maintenance mode ON
5. Deploy backend (git push, migrations run automatically)
6. Deploy frontend
7. Run: heroku run rake billing:recalculate
8. Verify admin panel loads, spot-check balances
9. Maintenance mode OFF
10. Schedule daily rake task
```
