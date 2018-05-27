class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def current_resident
    @current_resident ||= Key.find_by(token: cookies[:token])&.identity
  end

  def current_resident_api
    @current_resident_api ||= Key.find_by(token: params[:token])&.identity
  end

  def signed_in_resident?
    current_resident.present?
  end

  def signed_in_resident_api?
    current_resident_api.present?
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

  def not_authenticated_api
    render json: {message: "You are not authenticated. Please try signing in and then try again."}, status: 401 and return
  end

  def not_authorized_api
    render json: {message: "You are not authorized to view the page. You may have mistyped the address or might be signed into the wrong account."}, status: 403 and return
  end

  def not_found_api
    render json: {message: "The page you were looking for doesn't exist. You may have mistyped the address or the page may have moved."}, status: 404 and return
  end
end
