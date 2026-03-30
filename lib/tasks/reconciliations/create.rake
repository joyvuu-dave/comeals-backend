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

      period_start = community.meals.unreconciled.joins(:bills).minimum(:date)
      period_end = Time.zone.today

      reconciliation = Reconciliation.create!(
        community: community,
        date: Time.zone.today,
        start_date: period_start,
        end_date: period_end
      )

      Rails.logger.info(
        "Reconciliation ##{reconciliation.id} created for #{community.name}: #{reconciliation.number_of_meals} meals"
      )

      Rake::Task['billing:recalculate'].invoke
      Rake::Task['billing:recalculate'].reenable

      reconciliation.unique_cooks.each do |cook|
        ReconciliationMailer.reconciliation_notify_email(cook, reconciliation).deliver_now
      rescue *MAIL_DELIVERY_ERRORS => e
        Rails.logger.error("reconciliation_notify_email failed for #{cook.email}: #{e.class} - #{e.message}")
      end
    end

    total_time = Time.current - start_time
    Rails.logger.info("reconciliations:create completed in #{total_time.round(2)}s")
  end
end
