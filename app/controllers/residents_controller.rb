class ResidentsController < ApplicationController
  VALID_CALENDAR_TYPES = ['all', 'birthdays', 'common-house', 'events', 'guest-room', 'meals']

  before_action :ensure_community, except: [:login, :password_reset, :password_new]
  before_action :set_resident, except: [:login, :password_reset, :password_new]
  before_action :validate_calendar, only: [:calendar]

  # GET /residents/login (www)
  def login
  end

  # GET /calendar/(:type) (subdomains)
  def calendar
    @hosts = @community&.residents.adult.active.joins(:unit).order("units.name").pluck("residents.id", "residents.name", "units.name")
    @residents = @community&.residents.adult.active.joins(:unit).order("units.name").pluck("residents.id", "residents.name", "units.name")
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

  private
  def ensure_community
    @community = Community.find_by(slug: subdomain)

    redirect_to :root and return if @community.nil?
  end

  def set_resident
    @resident_id = current_resident&.id
    @resident = current_resident
  end

  def validate_calendar
    @calendar_type = params[:type] || 'all'

    render file: "#{Rails.root}/public/404.html", status: 404, layout: false and return unless VALID_CALENDAR_TYPES.include?(@calendar_type)
  end

end
