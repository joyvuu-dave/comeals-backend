class ApplicationController < ActionController::Base
  include Pundit
  before_action :handle_invalid_domain

  def current_identity
    case request.format
    when Mime[:atom]
      array = ActionController::HttpAuthentication::Token.token_and_options(request)
      @current_identity ||= Key.find_by(token: array.nil? ? nil : array[0])&.identity
    else
      @current_identity = Key.find_by(token: cookies[:token])&.identity
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

  def current_community
    @current_community ||= Community.find_by(slug: subdomain)
  end

  def subdomain
    @subdomain ||= request.subdomain
  end

  def invalid_domain?
    current_community.nil? && !['www', 'admin', 'api', ''].include?(subdomain)
  end

  def handle_invalid_domain
    if invalid_domain?
      render html: "<h1>Invalid Domain: #{subdomain}</h1>".html_safe, status: :bad_request and return
    end
  end
end
