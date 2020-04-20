class ReconciliationMailer < ApplicationMailer
  default from: 'webmaster@comeals.com'

  def reconciliation_notify_email(resident, reconciliation)
    @resident = resident
    @community = @resident.community
    @url = "#{admin_root_url}/bills?order=meals.date_desc&q%5Bmeal_reconciliation_id_eq%5D=#{reconciliation.id}&q%5Bresident_id_eq%5D=#{resident.id}&subdomain=admin&token=#{ENV['READ_ONLY_ADMIN_TOKEN']}&utf8=%E2%9C%93"
    mail(to: @resident.email, subject: "Meal Reconciliation #{reconciliation.id}")
  end
end
