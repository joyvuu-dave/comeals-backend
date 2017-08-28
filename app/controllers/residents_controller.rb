class ResidentsController < ApplicationController
  # GET /residents/login (www)
  def login
  end

  # GET /residents/calendar (subdomains)
  def calendar
    @community = Community.find_by(slug: subdomain)
  end

  # GET /residents/password-reset
  def password_reset
  end

  # GET /residents/password-reset/:token
  def password_new
    resident = Resident.find_by(reset_password_token: params[:token])
    @email = resident&.email
    @token = resident&.reset_password_token
  end

end
