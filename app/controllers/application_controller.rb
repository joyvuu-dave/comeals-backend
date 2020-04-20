class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  # GET /admin-logout (admin)
  def admin_logout
    cookies.delete(:remember_admin_user_token)
    reset_session
    redirect_to '/'
  end

  def access_denied(exception)
    redirect_to '/401'
  end

  def authenticate_admin_user_custom!
    if params[:token].present? && params[:token] == ENV['READ_ONLY_ADMIN_TOKEN'] then 
      return false
    else
      send(:authenticate_admin_user!)
    end
  end


  def current_admin_user_custom
    if params[:token].present? && params[:token] == ENV['READ_ONLY_ADMIN_TOKEN'] then 
      return AdminUser.find(ENV['READ_ONLY_ADMIN_ID'])
    else
      send(:current_admin_user)
    end
  end
end
