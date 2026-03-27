# == Schema Information
#
# Table name: meal_residents
#
#  id           :bigint           not null, primary key
#  late         :boolean          default(FALSE), not null
#  multiplier   :integer          not null
#  vegetarian   :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#  meal_id      :bigint           not null
#  resident_id  :bigint           not null
#
# Indexes
#
#  index_meal_residents_on_community_id             (community_id)
#  index_meal_residents_on_meal_id                  (meal_id)
#  index_meal_residents_on_meal_id_and_resident_id  (meal_id,resident_id) UNIQUE
#  index_meal_residents_on_resident_id              (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (meal_id => meals.id)
#  fk_rails_...  (resident_id => residents.id)
#

require 'rails_helper'

RSpec.describe MealResident, type: :model do
  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }
  let(:meal) { FactoryBot.create(:meal, community: community) }
  let(:resident) { FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2) }

  describe '#cost' do
    it 'returns meal unit_cost multiplied by multiplier as BigDecimal' do
      FactoryBot.create(:meal_resident, meal: meal, resident: resident, community: community)
      meal.reload

      another_resident = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 1)
      mr = FactoryBot.create(:meal_resident, meal: meal, resident: another_resident, community: community)
      meal.reload

      # Total multiplier = 2 + 1 = 3
      FactoryBot.create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal("90"))
      meal.reload

      # unit_cost = 90 / 3 = 30, mr.multiplier = 1, cost = 30 * 1 = 30
      expect(mr.cost).to be_a(BigDecimal)
      expect(mr.cost).to eq(BigDecimal("30"))
    end
  end

  describe '#set_multiplier' do
    it 'copies the resident multiplier before validation' do
      mr = MealResident.new(meal: meal, resident: resident)
      mr.valid?

      expect(mr.multiplier).to eq(resident.multiplier)
    end

    it 'copies a child multiplier of 1' do
      child = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 1)
      mr = MealResident.new(meal: meal, resident: child)
      mr.valid?

      expect(mr.multiplier).to eq(1)
    end
  end

  describe '#set_community_id' do
    it 'copies the meal community_id before validation' do
      mr = MealResident.new(meal: meal, resident: resident)
      mr.valid?

      expect(mr.community_id).to eq(meal.community_id)
    end
  end

  describe '#meal_has_open_spots' do
    it 'allows signup when meal is open' do
      meal.update_columns(closed: false)

      mr = MealResident.new(meal: meal, resident: resident)
      mr.valid?

      expect(mr.errors[:base]).to be_empty
    end

    it 'allows signup when meal is closed with max set and spots available' do
      meal.update_columns(closed: true, closed_at: 1.hour.ago, max: 5)

      mr = MealResident.new(meal: meal, resident: resident)
      mr.valid?

      expect(mr.errors[:base]).to be_empty
    end

    it 'rejects signup when meal is closed without max' do
      meal.update_columns(closed: true, closed_at: 1.hour.ago, max: nil)

      mr = MealResident.new(meal: meal, resident: resident)
      mr.valid?

      expect(mr.errors[:base]).to include("Meal has been closed.")
    end

    it 'rejects signup when meal is closed with max and no spots available' do
      # Create 2 attendees to fill the meal
      other_unit = FactoryBot.create(:unit, community: community)
      attendee_1 = FactoryBot.create(:resident, community: community, unit: other_unit, multiplier: 2)
      attendee_2 = FactoryBot.create(:resident, community: community, unit: other_unit, multiplier: 2)
      FactoryBot.create(:meal_resident, meal: meal, resident: attendee_1, community: community)
      FactoryBot.create(:guest, meal: meal, resident: attendee_2, multiplier: 2)
      meal.update_columns(closed: true, closed_at: 1.hour.ago, max: 2)

      mr = MealResident.new(meal: meal, resident: resident)
      mr.valid?

      expect(mr.errors[:base]).to include("Meal has no open spots.")
    end
  end

  describe '#record_can_be_removed' do
    it 'allows removal when meal is open' do
      mr = FactoryBot.create(:meal_resident, meal: meal, resident: resident, community: community)

      expect { mr.destroy }.to change(MealResident, :count).by(-1)
    end

    it 'allows removal when resident signed up after meal was closed' do
      meal.update_columns(closed: true, closed_at: 1.hour.ago, max: 5)
      mr = FactoryBot.create(:meal_resident, meal: meal, resident: resident, community: community)

      expect { mr.destroy }.to change(MealResident, :count).by(-1)
    end

    it 'blocks removal when resident signed up before meal was closed' do
      mr = FactoryBot.create(:meal_resident, meal: meal, resident: resident, community: community)
      # Set closed_at to after the meal_resident was created
      meal.update_columns(closed: true, closed_at: DateTime.now + 1.hour)

      expect { mr.destroy }.not_to change(MealResident, :count)
      expect(mr.errors[:base]).to include("Meal has been closed.")
    end
  end
end
