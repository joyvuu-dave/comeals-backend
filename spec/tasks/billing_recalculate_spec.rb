require 'rails_helper'
require 'rake'

RSpec.describe 'billing:recalculate' do
  before(:all) do
    Rails.application.load_tasks
  end

  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }

  after do
    Rake::Task['billing:recalculate'].reenable
  end

  it 'computes and stores resident balances from source data' do
    cook = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
    eater = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
    meal = FactoryBot.create(:meal, community: community)

    FactoryBot.create(:meal_resident, meal: meal, resident: eater, community: community)
    FactoryBot.create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal("60"))
    meal.reload

    Rake::Task['billing:recalculate'].invoke

    cook_balance = ResidentBalance.find_by(resident: cook)
    eater_balance = ResidentBalance.find_by(resident: eater)

    expect(cook_balance).to be_present
    expect(cook_balance.amount).to eq(BigDecimal("60"))

    expect(eater_balance).to be_present
    expect(eater_balance.amount).to eq(BigDecimal("-60"))
  end

  it 'corrects drifted multiplier sums' do
    meal = FactoryBot.create(:meal, community: community)
    resident = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
    FactoryBot.create(:meal_resident, meal: meal, resident: resident, community: community)

    # Simulate drift
    meal.update_column(:meal_residents_multiplier, 99)

    Rake::Task['billing:recalculate'].invoke

    meal.reload
    expect(meal.meal_residents_multiplier).to eq(2)
  end

  it 'excludes reconciled meals from balance calculations' do
    reconciliation = Reconciliation.create!(community: community, date: Date.today)
    resident = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)

    # Reconciled meal with big bill — should NOT affect balance
    reconciled_meal = FactoryBot.create(:meal, community: community, reconciliation: reconciliation)
    FactoryBot.create(:bill, meal: reconciled_meal, resident: resident, community: community, amount: BigDecimal("500"))

    # Unreconciled meal — cook and attend = 0 balance
    unreconciled_meal = FactoryBot.create(:meal, community: community)
    FactoryBot.create(:meal_resident, meal: unreconciled_meal, resident: resident, community: community)
    FactoryBot.create(:bill, meal: unreconciled_meal, resident: resident, community: community, amount: BigDecimal("30"))

    Rake::Task['billing:recalculate'].invoke

    balance = ResidentBalance.find_by(resident: resident)
    expect(balance.amount).to eq(BigDecimal("0"))
  end

  it 'handles residents with no meals gracefully' do
    resident = FactoryBot.create(:resident, community: community, unit: unit)

    Rake::Task['billing:recalculate'].invoke

    balance = ResidentBalance.find_by(resident: resident)
    expect(balance).to be_present
    expect(balance.amount).to eq(BigDecimal("0"))
  end
end
