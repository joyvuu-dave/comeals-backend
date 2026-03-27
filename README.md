# Comeals

This app was designed to allow
[Cohousing](https://en.wikipedia.org/wiki/Cohousing) communities to reconcile
the cost of common meals.

## Getting Started

```bash
git clone https://github.com/joyvuu-dave/comeals-backend.git
cd comeals-backend
bundle install
bundle exec rake db:setup
bundle exec rails s
```

## Local URLs

- **Rails API**: http://localhost:3000
- **Admin console**: http://admin.lvh.me:3000/login (`lvh.me` resolves to 127.0.0.1, required for subdomain routing)
- **Frontend**: http://localhost:3001 (run `PORT=3001 npm start` from the [comeals-ui](https://github.com/joyvuu-dave/comeals-ui) repo)

## Rake Tasks

- `rake billing:recalculate` — refresh resident balances from source data (run daily in production)
- `rake reconciliations:create` — close a billing period and compute settlement balances
