class StaticController < ApplicationController
  # GET / (www)
  def main
    if Rails.env.production?
      host = "https://"
      top_level = ".com"
    else
      host = "http://"
      top_level = ".test"
    end

    if current_admin_user.present?
      redirect_to "#{host}admin.comeals#{top_level}" and return
    end

    if signed_in_resident?
      redirect_to "#{host}#{current_resident.community.slug}.comeals#{top_level}/calendar/all" and return
    end
  end

  # GET /admin-logout (admin)
  def admin_logout
    if Rails.env.production?
      host = "https://"
      top_level = ".com"
    else
      host = "http://"
      top_level = ".test"
    end

    cookies.delete(:remember_admin_user_token)
    reset_session
    redirect_to "#{host}comeals#{top_level}"
  end

  # GET / (root, subdomains)
  def root
    if Rails.env.production?
      host = "https://"
      top_level = ".com"
    else
      host = "http://"
      top_level = ".test"
    end

    if current_admin_user.present?
      redirect_to "#{host}admin.comeals#{top_level}" and return
    elsif signed_in_resident?
      redirect_to "#{host}#{current_resident.community.slug}.comeals#{top_level}/calendar/all" and return
    else
      redirect_to "#{host}www.comeals#{top_level}" and return
    end
  end

end
