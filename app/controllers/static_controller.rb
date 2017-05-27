class StaticController < ApplicationController
  def main
  end

  def root
    if signed_in_manager?
      redirect_to "http://www.comeals.dev/manager/#{current_manager.id}" and return
    elsif signed_in_resident?
      redirect_to "http://#{current_resident.community.slug}.comeals.dev/calendar" and return
    else
      redirect_to "http://www.comeals.dev" and return
    end
  end

end
