# == Schema Information
#
# Table name: bills
#
#  id              :integer          not null, primary key
#  meal_id         :integer          not null
#  resident_id     :integer          not null
#  community_id    :integer          not null
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_bills_on_community_id             (community_id)
#  index_bills_on_meal_id                  (meal_id)
#  index_bills_on_meal_id_and_resident_id  (meal_id,resident_id) UNIQUE
#  index_bills_on_resident_id              (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (meal_id => meals.id)
#  fk_rails_...  (resident_id => residents.id)
#

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

  it 'has correct max_amount when cost is capped' do
    # Scenario: Community has a capped per person cost
    community = FactoryGirl.create(:community, cap: 250)
    meal = FactoryGirl.create(:meal, community_id: community.id)

    unit = FactoryGirl.create(:unit, community_id: community.id)
    resident_1 = FactoryGirl.create(:resident, community_id: community.id)
    resident_2 = FactoryGirl.create(:resident, community_id: community.id)

    meal_resident = FactoryGirl.create(:meal_resident, meal_id: meal.id, resident_id: resident_1.id, community_id: community.id)
    meal.reload

    bill_1 = FactoryGirl.create(:bill, meal_id: meal.id, resident_id: resident_1.id, community_id: community.id, amount_cents: 200)
    bill_1.reload

    bill_2 = FactoryGirl.create(:bill, meal_id: meal.id, resident_id: resident_2.id, community_id: community.id, amount_cents: 600)
    bill_2.reload

    meal.reload

    expect(bill_1.max_amount).to eq(0.25 * meal.max_cost)
  end
end
