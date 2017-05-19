class StaticController < ApplicationController
  before_action :inspect_subdomain

  def index
    # Scenario #1: manager pages
    if @subdomain == 'www'
      if signed_in_manager?
        redirect_to "/manager/#{current_manager.id}" and return
      end

      if signed_in_resident?
        redirect_to "#{request.protocol}#{current_resident.community.slug}.#{request.host}/calendar" and return
      end

      render html: "<h1>Welcome to Comeals! Start managing your community now!</h1>".html_safe and return
    end

    # Scenario #2: api routes
    if @subdomain == 'api'
      render json: { error: "No resource at root" }, status: :bad_request and return
    end

    if @subdomain == 'admin'
      redirect_to 'https://admin.comeals.dev/login' and return
    end

    # Scenario #3: no subdomain
    if @subdomain.blank?
      if signed_in_resident?
        redirect_to "#{request.protocol}#{current_resident.community.slug}.#{request.host}" and return
      else
        redirect_to "#{request.protocol}www.#{request.host}" and return
      end
    end

    # Scenario #4: member pages
    if !['www', 'api', 'admin', ''].include?(@subdomain) && signed_in_resident?
      redirect_to "#{request.protocol}#{current_resident.community.slug}.#{request.host}/calendar" and return
    end

    if !['www', 'api', 'admin', ''].include?(@subdomain) && !signed_in_resident?
      if current_community.present?
        redirect_to '/login' and return
      else
        render html: '<h1>That community does not exist.</h1>'.html_safe and return
      end
    end

  end

  private
  def inspect_subdomain
    @subdomain ||= request.subdomain
  end
end
