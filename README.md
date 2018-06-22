# Comeals

This app was designed to allow
[Cohousing](https://en.wikipedia.org/wiki/Cohousing) communities to reconcile
the cost of common meals.

## Getting Started

- `git clone https://github.com/joyvuu-dave/comeals-rewrite.git`
- `bundle install`
- `yarn install`
- `bundle exec rake db:setup`
- Configure project with `puma-dev` (https://github.com/puma/puma-dev)
- Production: `./bin/rake assets:precompile`
- Development: `./bin/webpack --watch --colors --progress`
- `workbox generateSW workbox-config.js`
- `open https://comeals.test/`
