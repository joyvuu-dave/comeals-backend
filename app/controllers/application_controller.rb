class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  # GET /admin-logout (admin)
  def admin_logout
    cookies.delete(:remember_admin_user_token)
    reset_session
    redirect_to '/'
  end

end
