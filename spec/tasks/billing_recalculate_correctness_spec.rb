require 'rails_helper'
require 'rake'

RSpec.describe 'billing:recalculate correctness', :benchmark, type: :task do
  before(:all) do
    Rails.application.load_tasks
  end

  after do
    Rake::Task['billing:recalculate'].reenable
  end

  it 'optimized rake task produces same results as per-resident calc_balance' do
    srand(42)

    # Build a community with varied meal data
    community = FactoryBot.create(:community, cap: BigDecimal("4.50"))
    unit = FactoryBot.create(:unit, community: community)

    residents = 10.times.map do |i|
      FactoryBot.create(:resident, community: community, unit: unit, multiplier: i < 7 ? 2 : 1)
    end

    # Create 20 meals with varied properties
    now = Time.current
    start_date = Date.new(2025, 6, 1)
    meal_rows = 20.times.map do |i|
      date = start_date + i.days
      {
        community_id: community.id,
        date: date,
        description: "",
        closed: false,
        cap: i % 3 == 0 ? nil : community.cap,
        start_time: date.to_datetime + 19.hours,
        created_at: now,
        updated_at: now
      }
    end
    Meal.insert_all(meal_rows)
    meals = Meal.where(community_id: community.id).order(:date).to_a

    # Bills (1-2 per meal, some no_cost)
    bill_rows = meals.flat_map do |meal|
      cook_count = rand(1..2)
      residents.sample(cook_count).map do |cook|
        {
          meal_id: meal.id,
          resident_id: cook.id,
          community_id: community.id,
          amount: BigDecimal(rand(15.0..60.0).round(2).to_s),
          no_cost: rand(100) < 10,
          created_at: now,
          updated_at: now
        }
      end
    end
    Bill.insert_all(bill_rows)

    # Meal residents (5-8 per meal)
    mr_rows = meals.flat_map do |meal|
      residents.sample(rand(5..8)).map do |resident|
        {
          meal_id: meal.id,
          resident_id: resident.id,
          community_id: community.id,
          multiplier: resident.multiplier,
          vegetarian: false,
          late: false,
          created_at: now,
          updated_at: now
        }
      end
    end
    MealResident.insert_all(mr_rows)

    # Guests (1-3 per meal)
    guest_rows = meals.flat_map do |meal|
      residents.sample(rand(1..3)).map do |host|
        {
          meal_id: meal.id,
          resident_id: host.id,
          multiplier: 2,
          name: "Guest",
          vegetarian: false,
          late: false,
          created_at: now,
          updated_at: now
        }
      end
    end
    Guest.insert_all(guest_rows)

    # Compute expected balances using the per-resident method (slow but correct oracle)
    expected = {}
    residents.each do |resident|
      expected[resident.id] = resident.calc_balance
    end

    # Run the optimized rake task
    Rake::Task['billing:recalculate'].reenable
    Rake::Task['billing:recalculate'].invoke

    # Verify each resident's cached balance matches the oracle.
    # Compare at DECIMAL(12,8) precision since that's what the DB stores.
    residents.each do |resident|
      cached = ResidentBalance.find_by(resident_id: resident.id)&.amount || BigDecimal("0")
      expect(cached.round(8)).to eq(expected[resident.id].round(8)),
        "Resident #{resident.name}: expected #{expected[resident.id].round(8)}, got #{cached.round(8)}"
    end
  end
end
