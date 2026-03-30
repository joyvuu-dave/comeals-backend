# frozen_string_literal: true

class ApiController < ActionController::API
  def root_url
    @root_url ||= Rails.env.production? ? 'https://comeals.com' : 'http://localhost:3001'
  end

  def current_resident_api
    @current_resident_api ||= Key.find_by(token: params[:token])&.identity
  end

  def signed_in_resident_api?
    current_resident_api.present?
  end

  def not_authenticated_api
    render json: { message: 'You are not authenticated. Please try signing in and then try again.' },
           status: :unauthorized and return
  end

  def not_authorized_api
    msg = 'You are not authorized to view the page. You may have mistyped ' \
          'the address or might be signed into the wrong account.'
    render json: { message: msg },
           status: :forbidden and return
  end

  def not_found_api
    msg = "The page you were looking for doesn't exist. You may have " \
          'mistyped the address or the page may have moved.'
    render json: { message: msg },
           status: :not_found and return
  end
end
