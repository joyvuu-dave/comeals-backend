# == Schema Information
#
# Table name: units
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#
# Indexes
#
#  index_units_on_community_id           (community_id)
#  index_units_on_community_id_and_name  (community_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#

require 'rails_helper'

RSpec.describe Unit, type: :model do
  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }

  describe '#balance' do
    it 'returns 0 when there are no unreconciled meals' do
      expect(unit.balance).to eq(0)
    end

    it 'sums resident balances from the resident_balances cache' do
      meal = FactoryBot.create(:meal, community: community)
      resident_a = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      resident_b = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)

      ResidentBalance.create!(resident: resident_a, amount: BigDecimal("25.50"))
      ResidentBalance.create!(resident: resident_b, amount: BigDecimal("-10.00"))

      expect(unit.balance).to eq(BigDecimal("15.50"))
    end

    it 'returns 0 when all meals are reconciled' do
      reconciliation = Reconciliation.create!(community: community, date: Date.today, start_date: 2.years.ago.to_date, end_date: Date.today)
      meal = FactoryBot.create(:meal, community: community)
      resident = FactoryBot.create(:resident, community: community, unit: unit)
      FactoryBot.create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal("50"))
      meal.update_column(:reconciliation_id, reconciliation.id)

      ResidentBalance.create!(resident: resident, amount: BigDecimal("50"))

      expect(unit.balance).to eq(0)
    end
  end

  describe '#meals_cooked' do
    it 'returns 0 when there are no unreconciled meals' do
      expect(unit.meals_cooked).to eq(0)
    end

    it 'counts bills for unreconciled meals across all unit residents' do
      meal_a = FactoryBot.create(:meal, community: community)
      meal_b = FactoryBot.create(:meal, community: community)
      resident_a = FactoryBot.create(:resident, community: community, unit: unit)
      resident_b = FactoryBot.create(:resident, community: community, unit: unit)

      FactoryBot.create(:bill, meal: meal_a, resident: resident_a, community: community, amount: BigDecimal("50"))
      FactoryBot.create(:bill, meal: meal_b, resident: resident_b, community: community, amount: BigDecimal("30"))

      expect(unit.meals_cooked).to eq(2)
    end

    it 'does not count bills for reconciled meals' do
      reconciliation = Reconciliation.create!(community: community, date: Date.today, start_date: 2.years.ago.to_date, end_date: Date.today)
      reconciled_meal = FactoryBot.create(:meal, community: community)
      unreconciled_meal = FactoryBot.create(:meal, community: community)
      resident = FactoryBot.create(:resident, community: community, unit: unit)

      FactoryBot.create(:bill, meal: reconciled_meal, resident: resident, community: community, amount: BigDecimal("50"))
      FactoryBot.create(:bill, meal: unreconciled_meal, resident: resident, community: community, amount: BigDecimal("30"))
      reconciled_meal.update_column(:reconciliation_id, reconciliation.id)

      expect(unit.meals_cooked).to eq(1)
    end
  end

  describe '#number_of_occupants' do
    it 'returns the residents_count' do
      FactoryBot.create(:resident, community: community, unit: unit)
      FactoryBot.create(:resident, community: community, unit: unit)
      unit.reload

      expect(unit.number_of_occupants).to eq(2)
    end

    it 'returns 0 when the unit has no residents' do
      expect(unit.number_of_occupants).to eq(0)
    end
  end
end
