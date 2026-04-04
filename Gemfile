# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '4.0.2'

# Individual Rails frameworks (instead of the `rails` meta-gem)
# to avoid installing unused gems (actionmailbox, actioncable, activestorage, actiontext)
gem 'actionmailer', '~> 8.1.0'
gem 'actionpack',   '~> 8.1.0'
gem 'actionview',   '~> 8.1.0'
gem 'activejob',    '~> 8.1.0'
gem 'activemodel',  '~> 8.1.0'
gem 'activerecord', '~> 8.1.0'
gem 'railties',     '~> 8.1.0'
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.5'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 7.0'
gem 'sassc-rails'

# Gems transitioning from stdlib to bundled gems in Ruby 3.4+
# (warnings in 3.3, required in 3.4)
gem 'base64'
gem 'bigdecimal'
gem 'csv'
gem 'drb'
gem 'mutex_m'

gem 'rack-cors', require: 'rack/cors'

gem 'activeadmin', '~> 3.0'
gem 'active_model_serializers', '~> 0.10'
gem 'audited'
gem 'dalli', '~> 3.2'
gem 'devise'
gem 'friendly_id'
gem 'goldiloader'
gem 'icalendar'
gem 'letter_opener', group: :development
gem 'platform-api'
gem 'pusher'
gem 'scrypt'
gem 'skylight', group: :production

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

group :development, :test do
  gem 'benchmark'
  gem 'byebug', platforms: %i[ruby mri windows]
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
end

group :test do
  gem 'simplecov', require: false
end

group :development do
  gem 'annotaterb'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'rack-mini-profiler'
  gem 'stackprof' # flamegraph support for rack-mini-profiler
  gem 'web-console', '>= 3.3.0'
  gem 'xipio'
end

gem 'oj'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[jruby windows]
