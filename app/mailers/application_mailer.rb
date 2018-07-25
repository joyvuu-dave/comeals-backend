class ApplicationMailer < ActionMailer::Base
  default from: 'webmaster@comeals.com'
  layout 'mailer'

  def root_url
    @root_url ||= Rails.env.production? ? "https://comeals.com" : "http://localhost:3001"
  end
end
