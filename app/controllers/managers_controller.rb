class ManagersController < ApplicationController
  def sign_up
  end

  def login
  end

  def show
  end

  def password_reset
    #render plain: "Password Reset (manager)\nManager: #{Key.find_by(params[:id]).identity.manager.email}"
    render plain: 'hi'
  end
end
