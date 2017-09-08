require 'rails_helper'

RSpec.describe Bill, type: :model do
  it 'adjusts reimbursable amount correctly' do
    # Scenario: Bill amount is not divisible by Meal multiplier
    community = FactoryGirl.create(:community)
    meal = FactoryGirl.create(:meal, community_id: community.id)

    unit_a = FactoryGirl.create(:unit, community_id: community.id)
    resident = FactoryGirl.create(:resident, community_id: community.id, multiplier: 3)

    meal_resident = FactoryGirl.create(:meal_resident, meal_id: meal.id, resident_id: resident.id, community_id: community.id)
    bill = FactoryGirl.create(:bill, meal_id: meal.id, resident_id: resident.id, community_id: community.id, amount_cents: 500)

    expect(bill.reimburseable_amount).to eq(501)
  end
end
