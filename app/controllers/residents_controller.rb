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
  end

  def password_new
    resident = Resident.find_by(reset_password_token: params[:token])
    @email = resident&.email
    @token = resident&.reset_password_token
  end

end
