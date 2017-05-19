class ApplicationController < ActionController::Base
  before_action :handle_invalid_domain

  include Pundit
  protect_from_forgery with: :exception

  def current_user
    # array = ActionController::HttpAuthentication::Token.token_and_options(request)
    # @current_user ||= Key.find_by(token: array.nil? ? nil : array[0])&.identity
    @current_user = nil
  end

  def current_manager
    @current_manager ||= current_user if current_user.class.equal?(Manager)
  end

  def signed_in_manager?
    current_manager.present?
  end

  def current_resident
    @current_resident ||= current_user if current_user.class.equal?(Resident)
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
      render plain: "Invalid Domain: #{subdomain}", status: :bad_request and return
    end
  end
end
