# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Comeals
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.app_generators.scaffold_controller = :scaffold_controller

    # Middleware for ActiveAdmin
    config.middleware.use Rack::MethodOverride
    config.middleware.use ActionDispatch::Flash
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    # CORS
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins(
          %r{\Ahttps?://([\w-]+\.)*comeals\.com\z}, # comeals.com and any subdomain(s)
          %r{\Ahttps?://localhost(:\d+)?\z}, # localhost (any port, for development)
          %r{\Ahttps?://([\w-]+\.)?lvh\.me(:\d+)?\z} # lvh.me and subdomains (for development)
        )
        resource '*', headers: :any, methods: %i[get post put patch delete options], credentials: true
      end
    end

    # Gzip response compression — must be early in the stack (outer middleware)
    # so it compresses the final response after all other middleware are done.
    config.middleware.insert_before Rack::Sendfile, Rack::Deflater

    # Disable Strong Params
    config.action_controller.permit_all_parameters = true

    # Set Time Zone
    config.time_zone = 'America/Los_Angeles'
  end
end
