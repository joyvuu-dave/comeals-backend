class ApplicationController < ActionController::Base
  include Pundit
  before_action :handle_invalid_domain

  def current_identity
    case request.format
    when Mime[:json]
      array = ActionController::HttpAuthentication::Token.token_and_options(request)
      Rails.logger.info "Auth token: #{array}"
      @current_identity ||= Key.find_by(token: array.nil? ? nil : array[0])&.identity
    else
      @current_identity ||= Key.find_by(token: cookies[:token])&.identity
    end
  end

  def current_manager
    @current_manager ||= current_identity if current_identity.class.equal?(Manager)
  end

  def signed_in_manager?
    current_manager.present?
  end

  def current_resident
    @current_resident ||= current_identity if current_identity.class.equal?(Resident)
  end

  def signed_in_resident?
    current_resident.present?
  end

  def signed_out?
    !signed_in_manager? && !signed_in_resident?
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
end
