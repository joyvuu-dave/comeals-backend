source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.3"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.0"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.5"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"
gem 'sassc-rails'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0'

gem 'rack-cors', :require => 'rack/cors'

gem 'activeadmin', '2.14.0'
gem 'devise'
gem 'friendly_id'
gem 'scrypt'
gem 'faker'
gem 'money-rails'
gem 'counter_culture'
gem 'active_model_serializers', '~> 0.10'
gem 'pusher'
gem 'audited'
gem 'newrelic_rpm'
gem 'sendgrid-ruby'
gem 'icalendar'
gem 'platform-api'
gem 'skylight'
gem 'goldiloader'
gem 'dalli'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:ruby, :mri, :mingw, :x64_mingw]
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
  gem 'annotate'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
