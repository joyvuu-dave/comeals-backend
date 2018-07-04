class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def current_resident
    @current_resident ||= Key.find_by(token: cookies[:token])&.identity
  end

  def signed_in_resident?
    current_resident.present?
  end

  def top_level
    @top_level ||= Rails.env.production? ? ".com" : ".test"
  end

  def not_authenticated
    redirect_to "https://www.comeals#{top_level}" and return
  end

  def not_authorized
    render file: "#{Rails.root}/public/403.html", status: 403, layout: false and return
  end

  def not_found
    render file: "#{Rails.root}/public/404.html", status: 404, layout: false and return
  end

  def version
    if Rails.env.production?
      require 'platform-api'
      heroku = PlatformAPI.connect_oauth(ENV['HEROKU_OAUTH_TOKEN'])
      begin
        @version = heroku.release.list('comeals').to_a.last["version"]
      rescue Exception => e
        Rails.logger.info e
        @version = 1
      end
    else
      @version = 0
    end

    @version
  end
end
