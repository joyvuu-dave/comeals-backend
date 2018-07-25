class ResidentMailer < ApplicationMailer
  default from: 'webmaster@comeals.com'

  def password_reset_email(resident)
    @resident = resident
    @url  = "#{root_url}/reset-password/#{@resident.reset_password_token}"
    mail(to: @resident.email, subject: 'Reset your password')
  end

  def rotation_signup_email(resident, rotation, open_meal_dates, community)
    @resident = resident
    @rotation  = rotation
    @community = community
    @open_meal_dates = open_meal_dates
    @url  = "#{root_url}"
    mail(to: @resident.email, subject: 'Sign up to Cook')
  end

  def new_rotation_email(resident, rotation, community)
    @rotation  = rotation
    @community = community

    @url  = "#{root_url}"
    mail(to: resident.email, subject: 'New Rotation Posted')
  end
end
