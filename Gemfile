source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.9"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 8.1.0"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.5"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 7.0"
gem 'sassc-rails'

# Gems transitioning from stdlib to bundled gems in Ruby 3.4+
# (warnings in 3.3, required in 3.4)
gem 'bigdecimal'
gem 'csv'
gem 'mutex_m'
gem 'base64'
gem 'drb'

gem 'concurrent-ruby'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0'

gem 'rack-cors', :require => 'rack/cors'

gem 'activeadmin', '~> 3.0'
gem 'devise'
gem 'friendly_id'
gem 'scrypt'
gem 'faker'
gem 'active_model_serializers', '~> 0.10'
gem 'pusher'
gem 'audited'
gem 'newrelic_rpm'
gem 'letter_opener', group: :development
gem 'icalendar'
gem 'platform-api'
gem 'skylight', group: :production
gem 'goldiloader'
gem 'dalli'
gem 'benchmark'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:ruby, :mri, :windows]
  gem 'rspec-rails'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'xipio'
  gem 'bullet'
  gem 'annotaterb'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:jruby, :windows]
