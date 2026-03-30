# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'billing:recalculate' do
  before(:all) do
    Rails.application.load_tasks
  end

  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }

  after do
    Rake::Task['billing:recalculate'].reenable
  end

  it 'computes and stores resident balances from source data' do
    cook = create(:resident, community: community, unit: unit, multiplier: 2)
    eater = create(:resident, community: community, unit: unit, multiplier: 2)
    meal = create(:meal, community: community)

    create(:meal_resident, meal: meal, resident: eater, community: community)
    create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal('60'))
    meal.reload

    Rake::Task['billing:recalculate'].invoke

    cook_balance = ResidentBalance.find_by(resident: cook)
    eater_balance = ResidentBalance.find_by(resident: eater)

    expect(cook_balance).to be_present
    expect(cook_balance.amount).to eq(BigDecimal('60'))

    expect(eater_balance).to be_present
    expect(eater_balance.amount).to eq(BigDecimal('-60'))
  end

  it 'excludes reconciled meals from balance calculations' do
    reconciliation = Reconciliation.create!(community: community, date: Time.zone.today,
                                            start_date: 2.years.ago.to_date,
                                            end_date: Time.zone.today)
    resident = create(:resident, community: community, unit: unit, multiplier: 2)

    # Reconciled meal with big bill — should NOT affect balance
    reconciled_meal = create(:meal, community: community, reconciliation: reconciliation)
    create(:bill, meal: reconciled_meal, resident: resident, community: community, amount: BigDecimal('500'))

    # Unreconciled meal — cook and attend = 0 balance
    unreconciled_meal = create(:meal, community: community)
    create(:meal_resident, meal: unreconciled_meal, resident: resident, community: community)
    create(:bill, meal: unreconciled_meal, resident: resident, community: community,
                  amount: BigDecimal('30'))

    Rake::Task['billing:recalculate'].invoke

    balance = ResidentBalance.find_by(resident: resident)
    expect(balance.amount).to eq(BigDecimal('0'))
  end

  it 'handles residents with no meals gracefully' do
    resident = create(:resident, community: community, unit: unit)

    Rake::Task['billing:recalculate'].invoke

    balance = ResidentBalance.find_by(resident: resident)
    expect(balance).to be_present
    expect(balance.amount).to eq(BigDecimal('0'))
  end
end
