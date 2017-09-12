module Api
  module V1
    class SiteController < ApplicationController
      def version
        if Rails.env.production?
          require 'platform-api'
          heroku = PlatformAPI.connect_oauth(ENV['HEROKU_OAUTH_TOKEN'])
          version = heroku.release.list('comeals').to_a.last["version"]
          render json: { version: version }
        else
          render json: { version: 1 }
        end
      end

    end
  end
end
