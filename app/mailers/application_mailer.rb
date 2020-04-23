class ApplicationMailer < ActionMailer::Base
  default from: 'webmaster@comeals.com'
  layout 'mailer'

  def root_url
    @root_url ||= Rails.env.production? ? "https://comeals.com" : "http://localhost:3001"
  end

  def root_admin_url
    @root_admin_url ||= Rail.env.production? ? "https://admin.comeals.com" : "http://admin.lvh.me:3000"
  end
end
