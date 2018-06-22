class StaticController < ApplicationController
  # GET / (www)
  def main
    if current_admin_user.present?
      redirect_to "https://admin.comeals#{top_level}" and return
    end

    if signed_in_resident?
      redirect_to "https://#{current_resident.community.slug}.comeals#{top_level}/calendar/all/#{Date.today.to_s}" and return
    end

    render file: "#{Rails.root}/public/index.html", status: 200, layout: false and return
  end

  # GET /admin-logout (admin)
  def admin_logout
    cookies.delete(:remember_admin_user_token)
    reset_session
    redirect_to "https://comeals#{top_level}"
  end

  # GET / (root, subdomains)
  def root
    if current_admin_user.present?
      redirect_to "https://admin.comeals#{top_level}" and return
    end

    if signed_in_resident?
      redirect_to "https://#{current_resident.community.slug}.comeals#{top_level}/calendar/all/#{Date.today.to_s}" and return
    end

    redirect_to "https://www.comeals#{top_level}" and return
  end

end
