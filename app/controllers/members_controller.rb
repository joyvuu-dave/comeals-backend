class MembersController < ApplicationController
  before_action :set_community

  def index
    render plain: 'Redirect to Calendar'
  end

  def login
    render html: "<h1>Login to #{current_community.name}!</h1>".html_safe
  end

  def calendar
  end

  def meal
    render plain: 'Meal'
  end

  def bill
    render plain: 'Bill'
  end

  def resident
    render plain: 'Resident'
  end

  def unit
    render plain: 'Unit'
  end

  def report
    render plain: 'Report'
  end

  def password_reset
    render plain: 'Password Reset (member)'
  end

  private
  def set_community
    @community = "Swan's Way"
  end
end
