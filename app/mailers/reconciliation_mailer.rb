class ReconciliationMailer < ApplicationMailer

  def reconciliation_notify_email(resident, reconciliation)
    @resident = resident
    @community = @resident.community
    @url = "#{root_admin_url}/bills?order=meals.date_desc&q%5Bmeal_reconciliation_id_eq%5D=#{reconciliation.id}&q%5Bresident_id_eq%5D=#{resident.id}&subdomain=admin&token=#{ENV['READ_ONLY_ADMIN_TOKEN']}&utf8=%E2%9C%93"
    mail(to: @resident.email, subject: "Meal Reconciliation #{reconciliation.id}")
  end

  def common_house_collection_email
    @resident_balances = "#{root_admin_url}/residents?q%5Bactive_eq%5D=true&commit=Filter&subdomain=admin&order=name_asc&token=#{ENV['READ_ONLY_ADMIN_TOKEN']}&utf8=%E2%9C%93"
    @unit_balances = "#{root_admin_url}/units?&token=#{ENV['READ_ONLY_ADMIN_TOKEN']}&utf8=%E2%9C%93"

    mail(to: "commonhouse@swansway.com", subject: "Reconciliation Balances")
  end
end
