class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :handle_invalid_domain
  before_action :set_version
  before_action :set_community

  def current_identity
    @current_identity ||= Key.find_by(token: cookies[:token])&.identity
  end

  def current_resident
    @current_resident ||= current_identity if current_identity.class.equal?(Resident)
  end

  def signed_in_resident?
    current_resident.present?
  end

  def signed_out?
    !signed_in_resident?
  end

  def subdomain
    @subdomain ||= request.subdomain
  end

  def invalid_domain?
    Community.find_by(slug: subdomain).nil? && !['www', 'admin', 'api', ''].include?(subdomain)
  end

  def handle_invalid_domain
    not_found if invalid_domain?
  end

  def not_found
    render file: "#{Rails.root}/public/404.html", status: 404, layout: false and return
  end

  def set_version
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

    cookies.permanent[:version] = {
      value: @version,
      domain: :all
    }
  end

  def set_community
    @community = Community.find_by(slug: subdomain)

    cookies.permanent[:community_id] = {
      value: @community&.id,
      domain: :all
    }
  end
end
