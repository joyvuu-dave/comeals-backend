# frozen_string_literal: true

namespace :reconciliations do
  desc 'Create a new reconciliation, assign unreconciled meals, recompute balances.'
  task create: :environment do
    start_time = Time.current

    Community.find_each do |community|
      unless community.meals.unreconciled.joins(:bills).exists?
        Rails.logger.info("reconciliations:create skipping #{community.name} — no unreconciled meals with bills")
        next
      end

      reconciliation = Reconciliation.create!(
        community: community,
        date: Date.today
      )

      Rails.logger.info(
        "Reconciliation ##{reconciliation.id} created for #{community.name}: #{reconciliation.number_of_meals} meals"
      )

      Rake::Task['billing:recalculate'].invoke
      Rake::Task['billing:recalculate'].reenable

      reconciliation.unique_cooks.each do |cook|
        ReconciliationMailer.reconciliation_notify_email(cook, reconciliation).deliver_now
      end
    end

    total_time = Time.current - start_time
    Rails.logger.info("reconciliations:create completed in #{total_time.round(2)}s")
  end
end
