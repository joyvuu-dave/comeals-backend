class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def current_resident
    @current_resident ||= Key.find_by(token: cookies[:token])&.identity
  end

  def signed_in_resident?
    current_resident.present?
  end

  def host
    @host ||= Rails.env.production? ? "https://" : "http://"
  end

  def top_level
    @top_level ||= Rails.env.production? ? ".com" : ".test"
  end

  def not_authenticated
    render file: "#{Rails.root}/public/401.html", status: 401, layout: false and return
  end

  def not_authorized
    render file: "#{Rails.root}/public/403.html", status: 403, layout: false and return
  end

  def not_found
    render file: "#{Rails.root}/public/404.html", status: 404, layout: false and return
  end
end
