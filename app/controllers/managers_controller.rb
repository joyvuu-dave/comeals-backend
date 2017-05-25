class ManagersController < ApplicationController
  def index
    render plain: "Comeals Homepage (manager)\nSigned In Manager: #{signed_in_manager?}\nSigned In Resident: #{signed_in_resident?}"
  end

  def sign_up
  end

  def login
  end

  def show
  end

  def community
    render plain: "Community Show Page (manager)\nManager: #{current_manager.email}\nCommunity: #{Community.find_by(params[:id]).name}"
  end

  def password_reset
    render plain: "Password Reset (manager)\nManager: #{Key.find_by(params[:id]).identity.manager.email}"
  end
end
