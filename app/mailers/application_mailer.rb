class ApplicationMailer < ActionMailer::Base
  default from: 'webmaster@comeals.com'
  layout 'mailer'

  def top_level
    @top_level ||= Rails.env.production? ? ".com" : ".test"
  end
end
