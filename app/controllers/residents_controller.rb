class ResidentsController < ApplicationController
  def login
    render layout: 'current_resident'
  end

  def calendar
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
