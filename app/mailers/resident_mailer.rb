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
end
