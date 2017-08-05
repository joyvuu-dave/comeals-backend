class StaticController < ApplicationController
  def main
  end

  def root
    if Rails.env.production?
      host = "https://"
      top_level = ".com"
    else
      host = "http://"
      top_level = ".dev"
    end

    if signed_in_manager?
      redirect_to "#{host}www.comeals#{top_level}/manager/#{current_manager.id}" and return
    elsif signed_in_resident?
      redirect_to "#{host}#{current_resident.community.slug}.comeals#{top_level}/calendar" and return
    else
      redirect_to "#{host}www.comeals#{top_level}" and return
    end
  end

end
