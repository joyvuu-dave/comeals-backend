class ResidentsController < ApplicationController
  before_action :ensure_community, except: [:login, :password_reset, :password_new]
  before_action :set_resident, except: [:login, :password_reset, :password_new]

  # GET /residents/login (www)
  def login
  end

  # GET /calendar (subdomains)
  def calendar
  end

  # GET /residents/guest-room (subdomains)
  def guest_room
  end

  # GET /residents/password-reset
  def password_reset
  end

  # GET /residents/password-reset/:token
  def password_new
    resident = Resident.find_by(reset_password_token: params[:token])
    @name = resident_name_helper(resident&.name)
    @token = resident&.reset_password_token
  end

  # GET /calendar/meals (subdomains)
  def meals_calendar
  end

  # GET /calendar/guest-room (subdomains)
  def guest_room_calendar
  end

  # GET /calendar/common-house (subdomains)
  def common_house_calendar
  end

  # GET /calendar/events (subdomains)
  def events_calendar
  end

  # GET /calendar/birthdays (subdomains)
  def birthdays_calendar
  end

  private
  def ensure_community
    @community = Community.find_by(slug: subdomain)

    redirect_to :root and return if @community.nil?
  end

  def set_resident
    @resident_id = current_resident&.id
    @resident = current_resident
  end

end
