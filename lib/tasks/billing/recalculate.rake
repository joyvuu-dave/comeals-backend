# frozen_string_literal: true

namespace :billing do
  desc 'Recalculate all resident balances from source records. Safe to run at any time.'
  task recalculate: :environment do
    start_time = Time.current

    Community.find_each do |community|
      # Batch-load all unreconciled meals with their financial associations (4 queries).
      # Uses preload (not includes) to guarantee separate IN(?) queries.
      # The joins(:bills).distinct excludes meals without bills — their unit_cost
      # is 0, so they contribute nothing to any resident's balance.
      unreconciled_meals = community.meals.unreconciled
                                    .joins(:bills).distinct
                                    .preload(:bills, :meal_residents, :guests).to_a

      # Precompute unit_cost per meal from in-memory data (0 queries).
      # Uses block-form .sum(&:field) which invokes Enumerable#sum on the
      # loaded array. The column-form .sum(:field) always fires SQL.
      unit_costs = {}
      unreconciled_meals.each do |meal|
        total_mult = meal.meal_residents.sum(&:multiplier) + meal.guests.sum(&:multiplier)

        if total_mult == 0
          unit_costs[meal.id] = BigDecimal("0")
          next
        end

        total_cost = meal.bills.reject(&:no_cost).sum(BigDecimal("0"), &:amount)
        effective_cost = total_cost
        if meal.capped?
          max_cost = meal.cap * total_mult
          effective_cost = max_cost if total_cost > max_cost
        end

        unit_costs[meal.id] = effective_cost / total_mult
      end

      # Accumulate credits, debits, and guest debits from in-memory data (0 queries).
      credits = Hash.new(BigDecimal("0"))
      debits = Hash.new(BigDecimal("0"))
      guest_debits = Hash.new(BigDecimal("0"))

      unreconciled_meals.each do |meal|
        uc = unit_costs[meal.id]
        meal.bills.each { |b| credits[b.resident_id] += b.amount unless b.no_cost }
        meal.meal_residents.each { |mr| debits[mr.resident_id] += uc * mr.multiplier }
        meal.guests.each { |g| guest_debits[g.resident_id] += uc * g.multiplier }
      end

      # Persist balances (1 query for residents, 1 write per changed balance).
      community.residents.find_each do |resident|
        balance = credits[resident.id] - debits[resident.id] - guest_debits[resident.id]

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
