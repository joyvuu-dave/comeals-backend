require 'rails_helper'

RSpec.describe Resident, type: :model do
  it 'has the correct balance' do
    # Scenario #1: resident attends meal
    community = FactoryGirl.create(:community)
    meal = FactoryGirl.create(:meal, community_id: community.id)

    unit = FactoryGirl.create(:unit, community_id: community.id)
    resident = FactoryGirl.create(:resident, community_id: community.id)

    meal_resident = FactoryGirl.create(:meal_resident, meal_id: meal.id, resident_id: resident.id, community_id: community.id)
    bill = FactoryGirl.create(:bill, meal_id: meal.id, resident_id: resident.id, community_id: community.id)

    expect(resident.balance).to eq(0)
  end
end
