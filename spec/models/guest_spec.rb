# == Schema Information
#
# Table name: guests
#
#  id          :bigint           not null, primary key
#  late        :boolean          default(FALSE), not null
#  multiplier  :integer          default(2), not null
#  name        :string           default(""), not null
#  vegetarian  :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  meal_id     :bigint           not null
#  resident_id :bigint           not null
#
# Indexes
#
#  index_guests_on_meal_id      (meal_id)
#  index_guests_on_resident_id  (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (meal_id => meals.id)
#  fk_rails_...  (resident_id => residents.id)
#

require 'rails_helper'

RSpec.describe Guest, type: :model do
  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }
  let(:meal) { FactoryBot.create(:meal, community: community) }
  let(:resident) { FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2) }

  describe '#cost' do
    it 'returns meal unit_cost multiplied by guest multiplier as BigDecimal' do
      mr = FactoryBot.create(:meal_resident, meal: meal, resident: resident, community: community)
      meal.reload

      # multiplier = 2 (from meal_resident)
      FactoryBot.create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal("50"))
      meal.reload

      guest = FactoryBot.create(:guest, meal: meal, resident: resident)
      meal.reload

      # Total multiplier = 2 (meal_resident) + 2 (guest default) = 4
      # unit_cost = 50 / 4 = 12.5
      # guest.cost = 12.5 * 2 = 25
      expect(guest.cost).to be_a(BigDecimal)
      expect(guest.cost).to eq(BigDecimal("25"))
    end
  end

  describe '#meal_has_open_spots' do
    it 'allows guest when max is nil' do
      meal.update_columns(max: nil)

      guest = Guest.new(meal: meal, resident: resident)
      guest.valid?

      expect(guest.errors[:base]).to be_empty
    end

    it 'allows guest when max is set and spots are available' do
      meal.update_columns(max: 10)

      guest = Guest.new(meal: meal, resident: resident)
      guest.valid?

      expect(guest.errors[:base]).to be_empty
    end

    it 'errors when max is set and no spots are available' do
      # Create 2 attendees to fill the meal
      other_unit = FactoryBot.create(:unit, community: community)
      filler_1 = FactoryBot.create(:resident, community: community, unit: other_unit, multiplier: 2)
      filler_2 = FactoryBot.create(:resident, community: community, unit: other_unit, multiplier: 2)
      FactoryBot.create(:meal_resident, meal: meal, resident: filler_1, community: community)
      FactoryBot.create(:guest, meal: meal, resident: filler_2, multiplier: 2)
      meal.update_columns(max: 2)

      guest = Guest.new(meal: meal, resident: resident)
      guest.valid?

      expect(guest.errors[:base]).to include("Meal has no open spots.")
    end
  end
end
