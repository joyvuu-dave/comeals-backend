class StaticController < ApplicationController
  # GET / (www)
  def main
    if current_admin_user.present?
      redirect_to "#{host}admin.comeals#{top_level}" and return
    end

    if signed_in_resident?
      redirect_to "#{host}#{current_resident.community.slug}.comeals#{top_level}/calendar/all/#{Date.today.to_s}" and return
    end

    @host = host
    @top_level = top_level
  end

  # GET /admin-logout (admin)
  def admin_logout
    cookies.delete(:remember_admin_user_token)
    reset_session
    redirect_to "#{host}comeals#{top_level}"
  end

  # GET / (root, subdomains)
  def root
    if current_admin_user.present?
      redirect_to "#{host}admin.comeals#{top_level}" and return
    end

    if signed_in_resident?
      redirect_to "#{host}#{current_resident.community.slug}.comeals#{top_level}/calendar/all/#{Date.today.to_s}" and return
    end

    redirect_to "#{host}www.comeals#{top_level}" and return
  end

end
