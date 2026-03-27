# frozen_string_literal: true

namespace :billing do
  desc 'Recalculate all resident balances from source records. Safe to run at any time.'
  task recalculate: :environment do
    start_time = Time.current

    Community.find_each do |community|
      community.residents.find_each do |resident|
        balance = resident.calc_balance

        record = ResidentBalance.find_or_initialize_by(resident_id: resident.id)
        if record.new_record? || record.amount != balance
          record.amount = balance
          record.save!
        end
      end
    end

    total_time = Time.current - start_time
    Rails.logger.info("billing:recalculate completed in #{total_time.round(2)}s")
  end
end
