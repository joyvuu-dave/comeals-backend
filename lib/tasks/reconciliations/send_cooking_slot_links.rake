namespace :reconciliations do

  desc "Send links to each cook's bills for given reconciliation period."
  task send_cooking_slot_email: :environment do
    start_time = Time.current

    r = Reconciliation.last
    
    r.unique_cooks.each do |cook|
      ReconciliationMailer.reconciliation_notify_email(cook, r).deliver_now
    end

    total_time = Time.current - start_time
    Rails.logger.info("Cooks' Reconciliation Email task Complete in #{total_time}s.")
  end
end
