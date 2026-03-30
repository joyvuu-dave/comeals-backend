# frozen_string_literal: true

class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  # GET /admin-logout (admin)
  def admin_logout
    cookies.delete(:remember_admin_user_token)
    reset_session
    redirect_to '/'
  end

  def access_denied(_exception)
    redirect_to '/401'
  end

  # Allow read-only admin access via a shared token (used in reconciliation
  # email links so cooks can view their bills without an admin account).
  # When the token matches, we skip Devise authentication and return a
  # designated read-only admin user instead.
  def authenticate_admin_user_custom!
    return if read_only_admin_token?

    authenticate_admin_user!
  end

  def current_admin_user_custom
    return AdminUser.find(ENV.fetch('READ_ONLY_ADMIN_ID', nil)) if read_only_admin_token?

    current_admin_user
  end

  private

  def read_only_admin_token?
    params[:token].present? && params[:token] == ENV['READ_ONLY_ADMIN_TOKEN']
  end
end
