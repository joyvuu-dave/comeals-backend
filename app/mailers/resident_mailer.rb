class ResidentMailer < ApplicationMailer
  default from: 'webmaster@comeals.com'

  def password_reset_email(resident)
    if Rails.env.production?
      host = "https://"
      top_level = ".com"
    else
      host = "http://"
      top_level = ".test"
    end

    @resident = resident
    @url  = "#{host}www.comeals#{top_level}/residents/password-reset/#{@resident.reset_password_token}"
    mail(to: @resident.email, subject: 'Reset your password')
  end

  def rotation_signup_email(resident, rotation, open_meal_dates, community)
    if Rails.env.production?
      host = "https://"
      top_level = ".com"
    else
      host = "http://"
      top_level = ".test"
    end

    @resident = resident
    @rotation  = rotation
    @community = community
    @open_meal_dates = open_meal_dates
    @url  = "#{host}#{@community.slug}.comeals#{top_level}/calendar"
    mail(to: @resident.email, subject: 'Sign up to cook')
  end
end
