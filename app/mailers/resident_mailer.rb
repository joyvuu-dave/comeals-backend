class ResidentMailer < ApplicationMailer
  default from: 'webmaster@comeals.com'

  def password_reset_email(resident)
    @resident = resident
    @url  = "https://www.comeals#{top_level}/reset-password/#{@resident.reset_password_token}"
    mail(to: @resident.email, subject: 'Reset your password')
  end

  def rotation_signup_email(resident, rotation, open_meal_dates, community)
    @resident = resident
    @rotation  = rotation
    @community = community
    @open_meal_dates = open_meal_dates
    @url  = "https://#{@community.slug}.comeals#{top_level}"
    mail(to: @resident.email, subject: 'Sign up to Cook')
  end

  def new_rotation_email(resident, rotation, community)
    @rotation  = rotation
    @community = community

    @url  = "https://#{community.slug}.comeals#{top_level}"
    mail(to: resident.email, subject: 'New Rotation Posted')
  end
end
