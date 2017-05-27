class ResidentsController < ApplicationController
  def login
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

end
