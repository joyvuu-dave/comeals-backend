class StaticController < ApplicationController
  before_action :inspect_subdomain

  def root_www
    if signed_in_manager?
      redirect_to "/manager/#{current_manager.id}" and return
    end

    if signed_in_resident?
      redirect_to current_resident_path and return
    end

    render 'static/main'
  end

  def root_api
    render json: { error: 'No resource.' }, status: :bad_request and return
  end

  def invalid_api
    render json: { error: 'Invalid resource.' }, status: :bad_request and return
  end

  def blank
    if signed_in_manager?
      redirect_to "#{request.protocol}www.#{request.host}" and return
    end

    if signed_in_resident?
      redirect_to "#{request.protocol}#{current_resident.community.slug}.#{request.host}" and return
    end

    redirect_to "#{request.protocol}www.comeals.dev"
  end

  def invalid_blank
    render html: "<h1>Invalid blank.</h1>".html_safe
  end

  def root_member
    if signed_in_resident?
      redirect_to current_resident_path and return
    end

    if !signed_in_resident?
      if current_community.present?
        redirect_to '/login' and return
      else
        render html: "<h1>No community with subdomain #{subdomain}.</h1>".html_safe and return
      end
    end
  end

  def invalid_member
    render html: "<h1>#{current_community.name} does not have that page.</h1>".html_safe
  end

  private
  def inspect_subdomain
    subdomain ||= request.subdomain
  end

  def current_resident_path
    @current_resident_path = "#{request.protocol}#{current_resident.community.slug}.#{request.host}/calendar"
  end
end
