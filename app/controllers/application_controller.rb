class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def current_resident
    @current_resident ||= Key.find_by(token: cookies[:token])&.identity
  end

  # GET /admin-logout (admin)
  def admin_logout
    cookies.delete(:remember_admin_user_token)
    reset_session
    redirect_to '/'
  end

end
