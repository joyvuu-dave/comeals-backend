# Heroku → Railway Migration Plan

**Created:** 2026-04-02
**Status:** Planning
**Goal:** Migrate comeals-backend (Rails API) and comeals-ui (React/Node) from Heroku to Railway with minimal downtime.

---

## Table of Contents

1. [Current Architecture](#1-current-architecture)
2. [Pre-Migration Setup](#2-pre-migration-setup)
3. [Practice Run with Spare Domain](#3-practice-run-with-spare-domain)
4. [Production Migration](#4-production-migration)
5. [DNS Cutover](#5-dns-cutover)
6. [Post-Migration Cleanup](#6-post-migration-cleanup)
7. [Rollback Plan](#7-rollback-plan)

---

## 1. Current Architecture

### Heroku Apps
| App | Type | Heroku Name | Production URL |
|-----|------|-------------|----------------|
| Backend | Rails 7 API | `comeals-backend` | `admin.comeals.com` |
| Frontend | React/Node (Express) | `comeals-ui` | `comeals.com` |

### Services & Add-ons
| Service | Current Provider | Notes |
|---------|-----------------|-------|
| PostgreSQL | Heroku Postgres | Source of truth for all data |
| Memcached | MemCachier (Heroku add-on) | Cache layer |
| Scheduled Jobs | Heroku Scheduler | `rake billing:recalculate` daily at 3am Pacific |
| APM | New Relic + Skylight | Performance monitoring |
| Real-time | Pusher | WebSocket push (external service, no migration needed) |
| Email | Gmail SMTP | External service, no migration needed |

### Environment Variables (Backend)
| Variable | Source | Railway Action |
|----------|--------|----------------|
| `RAILS_ENV` | Heroku default | Set to `production` |
| `RAILS_MAX_THREADS` | Heroku config | Set to `1` |
| `WEB_CONCURRENCY` | Heroku config | Set to `2` |
| `RAILS_LOG_TO_STDOUT` | Heroku config | Set to `true` |
| `SECRET_KEY_BASE` | Heroku config | Copy from Heroku or generate new |
| `DATABASE_URL` | Heroku Postgres | Use `${{Postgres.DATABASE_URL}}` reference |
| `MEMCACHIER_SERVERS` | MemCachier add-on | See [Memcached decision](#memcached-decision) |
| `MEMCACHIER_USERNAME` | MemCachier add-on | See [Memcached decision](#memcached-decision) |
| `MEMCACHIER_PASSWORD` | MemCachier add-on | See [Memcached decision](#memcached-decision) |
| `COMEALS_DATABASE_PASSWORD` | Heroku config | Not needed if using `DATABASE_URL` |
| `GMAIL_USERNAME` | Heroku config | Copy as-is |
| `GMAIL_APP_PASSWORD` | Heroku config | Copy as-is |
| `HEROKU_OAUTH_TOKEN` | Heroku config | **Remove** — replace version endpoint |
| `READ_ONLY_ADMIN_TOKEN` | Heroku config | Copy as-is |
| `MAILER_FROM_ADDRESS` | Heroku config (or defaults to `admin@comeals.com`) | Copy as-is |

### Environment Variables (Frontend)
| Variable | Source | Railway Action |
|----------|--------|----------------|
| `PORT` | Heroku default | Railway sets automatically |
| `API_URL` | Heroku config | Set to Railway backend's private URL |
| `NODE_ENV` | Heroku default | Set to `production` |

### Hardcoded Domain References (14 locations)
These must be updated if the domain changes (practice domain) or made configurable:

**Backend:**
1. `bin/deploy` lines 16-17 — `comeals.com`, `admin.comeals.com`
2. `config/application.rb` line 53 — CORS regex for `comeals.com`
3. `config/environments/production.rb` line 95 — mailer host `admin.comeals.com`
4. `config/environments/production.rb` line 102 — SMTP domain `comeals.com`
5. `config/initializers/devise.rb` line 19 — mailer sender `admin@comeals.com`
6. `app/mailers/application_mailer.rb` lines 4, 8, 12 — email URLs
7. `app/controllers/api_controller.rb` line 5 — root URL
8. `app/assets/javascripts/active_admin.js.coffee` line 54 — admin link

**Frontend:**
9. `src/components/calendar/webcal_links.jsx` lines 47, 55 — `api.comeals.com`
10. `index.html` line 34 — idle timeout redirect

---

## 2. Pre-Migration Setup

### Step 2.1: Install Railway CLI and Plugin
```bash
# Install Railway CLI
brew install railway

# Authenticate
railway login

# Install Claude Code plugin (gives Claude direct Railway management)
# In Claude Code:
/plugin marketplace add railwayapp/railway-skills
/plugin install railway@railway-skills
```

### Step 2.2: Create DNSimple API Token
1. Log in to DNSimple dashboard
2. Go to **Account → Access Tokens**
3. Create a new **Account Token** (not user token)
4. Save as environment variable locally:
   ```bash
   export DNSIMPLE_TOKEN="your-token-here"
   export DNSIMPLE_ACCOUNT_ID="your-account-id"
   ```
5. Verify access:
   ```bash
   curl -s -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
     "https://api.dnsimple.com/v2/$DNSIMPLE_ACCOUNT_ID/zones" | jq .
   ```

### Step 2.3: Inventory Current DNS Records
```bash
# List all records for comeals.com
curl -s -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
  "https://api.dnsimple.com/v2/$DNSIMPLE_ACCOUNT_ID/zones/comeals.com/records" | jq .
```
Save this output — it's your DNS backup and reference for the cutover.

### Step 2.4: Update database.yml to Support DATABASE_URL
Railway (like Heroku) provides `DATABASE_URL`. Rails automatically uses it when present, but the explicit `production:` config in `database.yml` may override it. Verify that `DATABASE_URL` takes precedence, or update the production config:

```yaml
production:
  url: <%= ENV['DATABASE_URL'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 1 } %>
```

### Step 2.5: Replace Heroku Version Endpoint
The `GET /api/v1/version` endpoint in `app/controllers/api/v1/site_controller.rb` uses the Heroku API (`platform-api` gem + `HEROKU_OAUTH_TOKEN`). This must be replaced.

**Options (pick one):**
- **A) Git SHA:** Set `RAILWAY_GIT_COMMIT_SHA` (Railway provides this automatically) and return it as the version.
- **B) Release timestamp:** Return `ENV['RAILWAY_DEPLOYMENT_ID']` or a build-time value.
- **C) Remove entirely:** If the frontend only uses this for display, consider removing it.

**Recommended:** Option A. Replace the Heroku API call with:
```ruby
def version
  render json: { version: ENV.fetch('RAILWAY_GIT_COMMIT_SHA', 'unknown')[0..7] }
end
```
Then remove the `platform-api` gem from the Gemfile.

### Step 2.6: Decide on Memcached {#memcached-decision}
Railway doesn't have a native MemCachier add-on. Options:

- **A) Railway Redis:** Use Railway's built-in Redis as a cache store instead of Memcached. Change `config.cache_store` from `:mem_cache_store` to `:redis_cache_store`. This is the simplest path.
- **B) External MemCachier:** Sign up for MemCachier directly (they offer standalone plans outside Heroku). Keep the same gem and config.
- **C) Drop caching:** If the app's cache needs are minimal, disable it entirely.

**Recommended:** Option A (Redis). Railway provisions Redis with one click, and Rails has built-in Redis cache store support.

### Step 2.7: Decide on Scheduled Jobs (Cron)
Heroku Scheduler runs `rake billing:recalculate` daily. Railway options:

- **A) Railway Cron Service:** Create a separate service in Railway with a cron schedule. Set it to run `bundle exec rake billing:recalculate` on a cron expression (e.g., `0 10 * * *` for 3am Pacific / 10am UTC).
- **B) External cron:** Use an external service (cron-job.org, EasyCron) to hit a webhook endpoint that triggers the rake task.

**Recommended:** Option A. Railway cron services are first-class. Create a separate service in the same project that shares the database connection.

### Step 2.8: Decide on APM
- **New Relic:** Works anywhere — just set the `NEW_RELIC_LICENSE_KEY` env var. No Heroku dependency.
- **Skylight:** Also works anywhere — set `SKYLIGHT_AUTHENTICATION` env var. No Heroku dependency.
- Both can continue as-is on Railway. No changes needed beyond ensuring env vars are set.

---

## 3. Practice Run with Spare Domain

Use your spare domain to validate the entire Railway setup before touching production.

### Step 3.1: Create Railway Project
```bash
railway init  # Create new project, name it "comeals-practice" or similar
```

### Step 3.2: Provision PostgreSQL
- In Railway dashboard: **+ New → Database → PostgreSQL**
- Or via CLI: `railway add` → select PostgreSQL

### Step 3.3: Provision Redis (if replacing MemCachier)
- In Railway dashboard: **+ New → Database → Redis**
- Or via CLI: `railway add` → select Redis

### Step 3.4: Create Backend Service
```bash
cd /Users/tejo/workspace/comeals-backend
railway link  # Link to the practice project, select/create backend service
railway up    # Deploy
```

Set environment variables in Railway dashboard (or via CLI):
```
RAILS_ENV=production
RAILS_MAX_THREADS=1
WEB_CONCURRENCY=2
RAILS_LOG_TO_STDOUT=true
SECRET_KEY_BASE=<generate with `rails secret`>
DATABASE_URL=${{Postgres.DATABASE_URL}}
REDIS_URL=${{Redis.REDIS_URL}}
GMAIL_USERNAME=<copy from Heroku>
GMAIL_APP_PASSWORD=<copy from Heroku>
MAILER_FROM_ADDRESS=admin@comeals.com
READ_ONLY_ADMIN_TOKEN=<copy from Heroku>
```

### Step 3.5: Create Frontend Service
```bash
cd /Users/tejo/workspace/comeals-ui
railway link  # Link to same practice project, create frontend service
railway up
```

Set environment variables:
```
API_URL=http://${{backend.RAILWAY_PRIVATE_DOMAIN}}:${{backend.PORT}}
NODE_ENV=production
```

**Note:** Using Railway's private networking so frontend→backend traffic stays internal.

### Step 3.6: Create Cron Service for Billing
In Railway dashboard:
1. **+ New → Empty Service**
2. Connect to the comeals-backend repo
3. Set start command: `bundle exec rake billing:recalculate`
4. Set schedule: cron expression `0 10 * * *` (3am Pacific = 10am UTC)
5. Set same database env vars as backend service

### Step 3.7: Assign Railway Domains
```bash
railway domain  # Assigns a *.up.railway.app domain to each service
```

### Step 3.8: Test with Railway Domains
- Verify backend health: `curl https://comeals-backend-practice.up.railway.app/api/v1/meals`
- Verify frontend loads: open `https://comeals-ui-practice.up.railway.app`
- Verify frontend→backend proxy works
- Verify database migrations ran (check Railway deploy logs)
- Verify cron service runs successfully (trigger manually first)

### Step 3.9: Attach Spare Domain
1. In Railway dashboard, add your spare domain as a custom domain to the frontend service
2. In Railway dashboard, add `admin.<spare-domain>` as a custom domain to the backend service (if you want to test admin)
3. Railway will show the CNAME target (e.g., `g05ns7.up.railway.app`)

### Step 3.10: Point Spare Domain DNS via DNSimple API
```bash
# Create ALIAS record for root domain → Railway
curl -s -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "https://api.dnsimple.com/v2/$DNSIMPLE_ACCOUNT_ID/zones/<spare-domain>/records" \
  -d '{"name": "", "type": "ALIAS", "content": "<railway-cname-target>", "ttl": 60}'

# Create CNAME for admin subdomain → Railway
curl -s -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "https://api.dnsimple.com/v2/$DNSIMPLE_ACCOUNT_ID/zones/<spare-domain>/records" \
  -d '{"name": "admin", "type": "CNAME", "content": "<railway-backend-cname-target>", "ttl": 60}'
```

### Step 3.11: Update Hardcoded Domains for Practice
Create a branch and temporarily replace `comeals.com` references with your spare domain to test:
- CORS origins
- Mailer URLs
- Webcal links
- Idle timeout redirect

**Do not merge this branch.** It's just for validation.

### Step 3.12: Validate Everything
- [ ] Frontend loads on spare domain with HTTPS (Let's Encrypt auto-provisioned)
- [ ] Admin panel loads on `admin.<spare-domain>`
- [ ] API requests from frontend to backend work
- [ ] Database reads/writes work
- [ ] Email sending works (password reset flow)
- [ ] Pusher real-time updates work
- [ ] Webcal subscription links work
- [ ] Cron job runs and completes successfully
- [ ] Cache (Redis) works
- [ ] SSL certificate is valid and auto-provisioned
- [ ] Idle timeout redirect works

---

## 4. Production Migration

After validating on the spare domain, proceed with production.

### Step 4.1: Create Production Railway Project
```bash
railway init  # Name: "comeals" or "comeals-production"
```
Provision PostgreSQL, Redis, backend service, frontend service, and cron service as in the practice run.

### Step 4.2: Migrate Production Database

**This is the most critical step. Rehearse it on the practice environment first.**

#### 4.2a: Take Heroku DB Backup
```bash
heroku pg:backups:capture --app comeals-backend
heroku pg:backups:download --app comeals-backend
# Downloads latest.dump
```

#### 4.2b: Get Railway PostgreSQL Connection String
From Railway dashboard, get the **public** connection string for the PostgreSQL service (TCP proxy URL).

#### 4.2c: Restore to Railway
```bash
pg_restore --verbose --clean --no-acl --no-owner \
  -d "<railway-postgres-public-url>" latest.dump
```

#### 4.2d: Verify Data Integrity
```bash
# Connect to Railway DB and spot-check
railway run rails console

# In console:
Meal.count
Resident.count
Bill.count
Reconciliation.count
# Compare counts with Heroku production
```

**Critical:** Verify DECIMAL(12,8) columns survived the dump/restore. Check a few bill amounts to full precision:
```ruby
Bill.first.amount.class  # Must be BigDecimal
Bill.first.amount.to_s('F')  # Check full precision preserved
```

### Step 4.3: Set All Production Environment Variables
Use Railway's "Import from Heroku" feature:
1. `railway open` → dashboard
2. Cmd+K → "Import variables from Heroku"
3. Review and adjust imported variables (remove Heroku-specific ones, add Railway-specific ones)

Or set manually (see Step 3.4 variable list, using production values).

### Step 4.4: Deploy Backend to Railway
```bash
cd /Users/tejo/workspace/comeals-backend
railway link  # Link to production project
railway up
```

Verify:
- Deploy logs show migrations running
- `curl https://<railway-backend-domain>/api/v1/meals` returns data
- Admin panel accessible

### Step 4.5: Deploy Frontend to Railway
```bash
cd /Users/tejo/workspace/comeals-ui
railway link  # Link to production project
railway up
```

Verify:
- Frontend loads on Railway domain
- API proxy to backend works

### Step 4.6: Add Custom Domains in Railway
Add these custom domains to Railway services:
- `comeals.com` → frontend service
- `admin.comeals.com` → backend service
- `api.comeals.com` → backend service (if webcal links use this)

Railway will provide CNAME targets for each.

### Step 4.7: Pre-Cutover Testing
Test the Railway deployment using the `*.up.railway.app` domains:
- [ ] All API endpoints return correct data
- [ ] Frontend renders and interacts correctly
- [ ] Admin panel works
- [ ] Meal signup flow works end-to-end
- [ ] Financial calculations produce correct results
- [ ] Email sending works
- [ ] Pusher notifications work

---

## 5. DNS Cutover

This is the moment of truth. The goal is to minimize the window where DNS points to neither Heroku nor Railway.

### Step 5.1: Lower TTLs (1 hour before cutover)
```bash
# List current records to get record IDs
curl -s -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
  "https://api.dnsimple.com/v2/$DNSIMPLE_ACCOUNT_ID/zones/comeals.com/records" | jq .

# Lower TTL on each record to 60 seconds
curl -s -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
  -H "Content-Type: application/json" \
  -X PATCH "https://api.dnsimple.com/v2/$DNSIMPLE_ACCOUNT_ID/zones/comeals.com/records/<RECORD_ID>" \
  -d '{"ttl": 60}'
```

### Step 5.2: Enable Heroku Maintenance Mode
```bash
heroku maintenance:on --app comeals-backend
heroku maintenance:on --app comeals-ui
```

### Step 5.3: Final Database Sync
Between enabling maintenance mode and switching DNS, do one final database dump/restore to capture any data written since Step 4.2:

```bash
heroku pg:backups:capture --app comeals-backend
heroku pg:backups:download --app comeals-backend
pg_restore --verbose --clean --no-acl --no-owner \
  -d "<railway-postgres-public-url>" latest.dump
```

### Step 5.4: Update DNS Records
```bash
# Update root domain (comeals.com) → Railway frontend CNAME target
# If current record is A/ALIAS, delete it and create new ALIAS:
curl -s -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
  -H "Content-Type: application/json" \
  -X PATCH "https://api.dnsimple.com/v2/$DNSIMPLE_ACCOUNT_ID/zones/comeals.com/records/<ROOT_RECORD_ID>" \
  -d '{"content": "<railway-frontend-cname-target>", "type": "ALIAS", "ttl": 60}'

# Update admin.comeals.com → Railway backend CNAME target
curl -s -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
  -H "Content-Type: application/json" \
  -X PATCH "https://api.dnsimple.com/v2/$DNSIMPLE_ACCOUNT_ID/zones/comeals.com/records/<ADMIN_RECORD_ID>" \
  -d '{"content": "<railway-backend-cname-target>", "ttl": 60}'

# Update api.comeals.com → Railway backend CNAME target (if it exists)
curl -s -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
  -H "Content-Type: application/json" \
  -X PATCH "https://api.dnsimple.com/v2/$DNSIMPLE_ACCOUNT_ID/zones/comeals.com/records/<API_RECORD_ID>" \
  -d '{"content": "<railway-backend-cname-target>", "ttl": 60}'
```

### Step 5.5: Verify DNS Propagation
```bash
# Check DNSimple's own propagation status
curl -s -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
  "https://api.dnsimple.com/v2/$DNSIMPLE_ACCOUNT_ID/zones/comeals.com/records/<RECORD_ID>/distribution" | jq .

# Check with dig
dig comeals.com
dig admin.comeals.com
dig api.comeals.com
```

### Step 5.6: Wait for SSL Certificate
Railway auto-provisions Let's Encrypt certificates after DNS verification. This can take up to 1 hour but is usually faster (~5-15 minutes). Monitor in Railway dashboard.

### Step 5.7: Verify Production on Railway
- [ ] `https://comeals.com` loads frontend
- [ ] `https://admin.comeals.com` loads admin panel
- [ ] API requests work through the frontend
- [ ] Meal signup works
- [ ] Login/logout works
- [ ] Password reset email sends with correct links
- [ ] Webcal links work (`webcal://api.comeals.com/...`)
- [ ] Pusher real-time updates work

### Step 5.8: Raise TTLs
Once everything is confirmed working:
```bash
# Raise TTL back to 3600 (1 hour)
curl -s -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
  -H "Content-Type: application/json" \
  -X PATCH "https://api.dnsimple.com/v2/$DNSIMPLE_ACCOUNT_ID/zones/comeals.com/records/<RECORD_ID>" \
  -d '{"ttl": 3600}'
```

---

## 6. Post-Migration Cleanup

### Step 6.1: Verify Cron Job
- Confirm `rake billing:recalculate` ran successfully on Railway
- Check `resident_balances` table is being refreshed

### Step 6.2: Monitor for 48 Hours
- Watch Railway logs for errors: `railway logs`
- Monitor response times via New Relic / Skylight
- Check that no requests are still hitting Heroku (Heroku logs)

### Step 6.3: Code Cleanup
- Remove `platform-api` gem from Gemfile (Heroku API client)
- Update `bin/deploy` script for Railway (or replace entirely)
- Update `DEPLOY_CHECKLIST.md` for Railway
- Remove Heroku git remotes:
  ```bash
  git remote remove heroku  # in both repos
  ```
- Update `CLAUDE.md` to reflect Railway hosting

### Step 6.4: Remove Hardcoded Credentials
While you're in the code, move these to environment variables:
- Pusher credentials in `config/initializers/pusher.rb`
- New Relic license key in `config/newrelic.yml`
- Skylight auth token in `config/skylight.yml`

### Step 6.5: Decommission Heroku
**Wait at least 1 week** after successful migration before deleting Heroku apps:
```bash
# Scale down to save costs while keeping as backup
heroku ps:scale web=0 --app comeals-backend
heroku ps:scale web=0 --app comeals-ui

# After 1 week of stable Railway operation:
heroku apps:destroy comeals-backend --confirm comeals-backend
heroku apps:destroy comeals-ui --confirm comeals-ui
```

---

## 7. Rollback Plan

If Railway has critical issues during or after cutover:

### Immediate Rollback (during cutover)
1. Point DNS back to Heroku:
   ```bash
   # Restore original DNS records (you saved them in Step 2.3)
   curl -s -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
     -H "Content-Type: application/json" \
     -X PATCH "https://api.dnsimple.com/v2/$DNSIMPLE_ACCOUNT_ID/zones/comeals.com/records/<RECORD_ID>" \
     -d '{"content": "<original-heroku-target>", "ttl": 60}'
   ```
2. Disable maintenance mode on Heroku:
   ```bash
   heroku maintenance:off --app comeals-backend
   heroku maintenance:off --app comeals-ui
   ```
3. If any data was written to Railway during the window, you'll need to manually reconcile or accept the loss (this is why the maintenance mode window should be as short as possible).

### Late Rollback (days after cutover)
1. Heroku apps are still running (just scaled to 0). Scale back up:
   ```bash
   heroku ps:scale web=1 --app comeals-backend
   heroku ps:scale web=1 --app comeals-ui
   ```
2. Export Railway database and import to Heroku to preserve any new data.
3. Point DNS back to Heroku.

---

## Estimated Downtime

| Phase | Duration | Impact |
|-------|----------|--------|
| Maintenance mode → DNS switch | ~5-10 min | Full downtime (planned) |
| DNS propagation | ~1-5 min | Varies by client ISP cache |
| SSL certificate provisioning | ~5-15 min | HTTPS may not work; HTTP may redirect |
| **Total estimated downtime** | **~15-30 min** | Schedule during low-usage time (not a common meal day) |

---

## Checklist Summary

### Pre-Migration
- [ ] Install Railway CLI (`brew install railway`)
- [ ] Install Railway Claude Code plugin
- [ ] Create DNSimple API token
- [ ] Save current DNS records snapshot
- [ ] Update `database.yml` to use `DATABASE_URL`
- [ ] Replace Heroku version endpoint
- [ ] Decide on Memcached replacement (Redis recommended)
- [ ] Test full flow on spare domain

### Cutover Day
- [ ] Lower DNS TTLs to 60s (1 hour before)
- [ ] Enable Heroku maintenance mode
- [ ] Final database dump/restore
- [ ] Update DNS records to Railway targets
- [ ] Verify DNS propagation
- [ ] Verify SSL certificates provisioned
- [ ] Full smoke test on production domain
- [ ] Raise DNS TTLs back to 3600

### Post-Migration
- [ ] Verify cron job runs
- [ ] Monitor for 48 hours
- [ ] Clean up code (remove Heroku dependencies)
- [ ] Move hardcoded credentials to env vars
- [ ] Update project documentation
- [ ] Scale Heroku to 0 (keep as backup for 1 week)
- [ ] Decommission Heroku after 1 week
