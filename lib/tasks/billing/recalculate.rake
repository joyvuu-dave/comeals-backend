namespace :billing do
  desc "Recalculate all financial data from source records. Safe to run at any time."
  task recalculate: :environment do
    start_time = Time.current

    Community.find_each do |community|
      # Phase 1: Verify and correct counter_culture cached values on meals.
      # Counter_culture maintains these for real-time display, but they can drift.
      # The source of truth is the child records, not the cached columns.
      community.meals.includes(:meal_residents, :guests).find_each do |meal|
        corrections = {}

        correct_mr_multiplier = meal.meal_residents.sum(:multiplier)
        corrections[:meal_residents_multiplier] = correct_mr_multiplier if meal.meal_residents_multiplier != correct_mr_multiplier

        correct_g_multiplier = meal.guests.sum(:multiplier)
        corrections[:guests_multiplier] = correct_g_multiplier if meal.guests_multiplier != correct_g_multiplier

        correct_mr_count = meal.meal_residents.count
        corrections[:meal_residents_count] = correct_mr_count if meal.meal_residents_count != correct_mr_count

        correct_g_count = meal.guests.count
        corrections[:guests_count] = correct_g_count if meal.guests_count != correct_g_count

        correct_bills_count = Bill.where(meal_id: meal.id).count
        corrections[:bills_count] = correct_bills_count if meal.bills_count != correct_bills_count

        if corrections.any?
          meal.update_columns(corrections)
          Rails.logger.info("billing:recalculate corrected meal #{meal.id}: #{corrections.keys.join(', ')}")
        end
      end

      # Phase 2: Recalculate resident balances from source data.
      # Credits = sum of bill amounts for unreconciled meals the resident cooked.
      # Debits = sum of (meal.unit_cost * multiplier) for unreconciled meals attended.
      # Guest debits = sum of (meal.unit_cost * guest.multiplier) for guests the resident hosted.
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
