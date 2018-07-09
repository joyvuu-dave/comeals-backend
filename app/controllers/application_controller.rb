class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def current_resident
    @current_resident ||= Key.find_by(token: cookies[:token])&.identity
  end

end
