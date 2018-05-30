class ResidentsController < ApplicationController
  include ApplicationHelper
  before_action :set_resident, only: [:password_new]
  before_action :authenticate, only: [:calendar]
  before_action :authorize, only: [:calendar]

  # GET /calendar/(:type)/(:date) (subdomains)
  def calendar
    unless params.has_key?(:type) && params.has_key?(:date)
      redirect_to "#{host}#{current_resident.community.slug}.comeals#{top_level}/calendar/all/#{Date.today.to_s}" and return
    end

    @version = version
    render 'meals/edit'
  end

  # GET /residents/password-reset/:token
  def password_new
    @name = resident_name_helper(@resident.name)
    @token = @resident.reset_password_token
    @version = version
  end

  private
  def set_resident
    @resident = Resident.find_by(reset_password_token: params[:token])
  end

  def authenticate
    not_authenticated unless signed_in_resident?
  end

  def authorize
    not_authorized unless current_resident.community.slug == request.subdomain
  end
end
