# frozen_string_literal: true

module Api
  module V1
    class SiteController < ApiController
      # GET /api/v1/version
      def version
        if Rails.env.production?
          require 'platform-api'
          heroku = PlatformAPI.connect_oauth(ENV.fetch('HEROKU_OAUTH_TOKEN', nil))
          begin
            version = heroku.release.list('comeals').to_a.last['version']
          rescue StandardError => e
            Rails.logger.info e
            version = 1
          end
          render json: { version: version }
        else
          render json: { version: 0 }
        end
      end
    end
  end
end
