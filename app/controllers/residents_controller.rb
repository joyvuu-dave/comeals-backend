class ResidentsController < ApplicationController
  # GET /residents/login (www)
  def login
  end

  # GET /calendar (subdomains)
  def calendar
    @community = Community.find_by(slug: subdomain)

    redirect_to :root and return if @community.nil?

    @resident_id = current_resident&.id
    @resident = current_resident
  end

  # GET /residents/guest-room (subdomains)
  def guest_room
    @community = Community.find_by(slug: subdomain)
    @resident_id = current_resident&.id
  end

  # GET /residents/profile (subdomains)
  def profile
    @community = Community.find_by(slug: subdomain)
    @resident_id = current_resident&.id
    @resident = current_resident
  end

  # GET /residents/react-calendar (subdomains)
  def react_calendar
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

  # GET /calendar/meals
  def meals_calendar
    @community = Community.find_by(slug: subdomain)

    redirect_to :root and return if @community.nil?

    @resident_id = current_resident&.id
    @resident = current_resident
  end

  # GET /calendar/guest-room
  def guest_room_calendar
    @community = Community.find_by(slug: subdomain)

    redirect_to :root and return if @community.nil?

    @resident_id = current_resident&.id
    @resident = current_resident
  end

  # GET /calendar/common-house
  def common_house_calendar
    @community = Community.find_by(slug: subdomain)

    redirect_to :root and return if @community.nil?

    @resident_id = current_resident&.id
    @resident = current_resident
  end

  # GET /calendar/events
  def events_calendar
    @community = Community.find_by(slug: subdomain)

    redirect_to :root and return if @community.nil?

    @resident_id = current_resident&.id
    @resident = current_resident
  end

  # GET /calendar/birthdays
  def birthdays_calendar
    @community = Community.find_by(slug: subdomain)

    redirect_to :root and return if @community.nil?

    @resident_id = current_resident&.id
    @resident = current_resident
  end

end
