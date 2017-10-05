source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.20'
# Use Puma as the app server
gem 'puma', '~> 3.8'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'webpacker', '~> 3.0.2'
gem 'annotate'
gem 'rack-cors', :require => 'rack/cors'
gem 'activeadmin'
gem 'devise'
gem 'pundit'
gem 'mini_racer'
gem 'friendly_id'
gem 'scrypt'
gem 'bootsnap'
gem 'faker'
gem 'money-rails'
gem 'counter_culture'
gem 'active_model_serializers', '~> 0.10'
gem 'pusher'
gem 'audited', '~> 4.5'
gem 'dalli'
gem 'connection_pool'
gem 'newrelic_rpm'
gem 'sendgrid-ruby'
gem 'icalendar'
gem 'font-awesome-sass'
gem 'platform-api'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:ruby, :mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.6'
  gem 'dotenv-rails'
  gem 'factory_girl_rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'xipio'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

ruby "2.4.2"
