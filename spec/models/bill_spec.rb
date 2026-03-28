# == Schema Information
#
# Table name: bills
#
#  id           :bigint           not null, primary key
#  amount       :decimal(12, 8)   default(0.0), not null
#  no_cost      :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#  meal_id      :bigint           not null
#  resident_id  :bigint           not null
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
  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }

  describe 'validations' do
    it 'rejects negative amounts' do
      meal = FactoryBot.create(:meal, community: community)
      resident = FactoryBot.create(:resident, community: community, unit: unit)
      bill = FactoryBot.build(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal("-1"))

      expect(bill).not_to be_valid
      expect(bill.errors[:amount]).to be_present
    end

    it 'enforces one bill per resident per meal' do
      meal = FactoryBot.create(:meal, community: community)
      resident = FactoryBot.create(:resident, community: community, unit: unit)
      FactoryBot.create(:bill, meal: meal, resident: resident, community: community)

      duplicate = FactoryBot.build(:bill, meal: meal, resident: resident, community: community)
      expect(duplicate).not_to be_valid
    end
  end

  describe '#set_community_id' do
    it 'copies community_id from the meal before validation' do
      meal = FactoryBot.create(:meal, community: community)
      resident = FactoryBot.create(:resident, community: community, unit: unit)
      bill = Bill.new(meal: meal, resident: resident, amount: BigDecimal("10"))

      bill.valid?
      expect(bill.community_id).to eq(community.id)
    end
  end

  describe '#reconciled?' do
    it 'returns true when the meal is reconciled' do
      reconciliation = FactoryBot.create(:reconciliation, community: community)
      meal = FactoryBot.create(:meal, community: community, reconciliation: reconciliation)
      resident = FactoryBot.create(:resident, community: community, unit: unit)
      bill = FactoryBot.create(:bill, meal: meal, resident: resident, community: community)

      expect(bill.reconciled?).to be true
    end

    it 'returns false when the meal is not reconciled' do
      meal = FactoryBot.create(:meal, community: community)
      resident = FactoryBot.create(:resident, community: community, unit: unit)
      bill = FactoryBot.create(:bill, meal: meal, resident: resident, community: community)

      expect(bill.reconciled?).to be false
    end
  end

  describe '#unit_cost' do
    it 'divides amount by meal multiplier using BigDecimal' do
      meal = FactoryBot.create(:meal, community: community)
      resident_a = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      resident_b = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 1)

      FactoryBot.create(:meal_resident, meal: meal, resident: resident_a, community: community)
      FactoryBot.create(:meal_resident, meal: meal, resident: resident_b, community: community)
      meal.reload

      # multiplier = 2 + 1 = 3
      bill = FactoryBot.create(:bill, meal: meal, resident: resident_a, community: community, amount: BigDecimal("50"))
      meal.reload

      expect(meal.multiplier).to eq(3)
      expect(bill.unit_cost).to be_a(BigDecimal)
      expect(bill.unit_cost).to eq(BigDecimal("50") / 3)
    end

    it 'returns 0 when meal multiplier is 0' do
      meal = FactoryBot.create(:meal, community: community)
      resident = FactoryBot.create(:resident, community: community, unit: unit)
      bill = FactoryBot.create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal("50"))

      expect(bill.unit_cost).to eq(BigDecimal("0"))
    end
  end

  describe '#effective_amount' do
    it 'returns the amount when no_cost is false' do
      meal = FactoryBot.create(:meal, community: community)
      resident = FactoryBot.create(:resident, community: community, unit: unit)
      bill = FactoryBot.create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal("50"))

      expect(bill.effective_amount).to eq(BigDecimal("50"))
    end

    it 'returns 0 when no_cost is true' do
      meal = FactoryBot.create(:meal, community: community)
      resident = FactoryBot.create(:resident, community: community, unit: unit)
      bill = FactoryBot.create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal("50"), no_cost: true)

      expect(bill.effective_amount).to eq(BigDecimal("0"))
    end
  end

  describe '#capped_amount' do
    it 'returns full amount when community has no cap' do
      meal = FactoryBot.create(:meal, community: community)
      resident = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      FactoryBot.create(:meal_resident, meal: meal, resident: resident, community: community)
      meal.reload

      bill = FactoryBot.create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal("75"))
      meal.reload

      expect(bill.capped_amount).to eq(BigDecimal("75"))
    end

    it 'proportionally reduces amount when meal cost exceeds cap' do
      capped_community = FactoryBot.create(:community, cap: BigDecimal("2.50"))
      capped_unit = FactoryBot.create(:unit, community: capped_community)
      meal = FactoryBot.create(:meal, community: capped_community)
      resident_1 = FactoryBot.create(:resident, community: capped_community, unit: capped_unit, multiplier: 2)
      resident_2 = FactoryBot.create(:resident, community: capped_community, unit: capped_unit, multiplier: 2)

      FactoryBot.create(:meal_resident, meal: meal, resident: resident_1, community: capped_community)
      meal.reload

      # multiplier = 2, cap = 2.50, max_cost = 5.00
      # Cook 1 submits $2.00, Cook 2 submits $6.00 = total $8.00 > $5.00 cap
      FactoryBot.create(:bill, meal: meal, resident: resident_1, community: capped_community, amount: BigDecimal("2"))
      FactoryBot.create(:bill, meal: meal, resident: resident_2, community: capped_community, amount: BigDecimal("6"))
      meal.reload

      # Fetch fresh bill instances so meal association isn't stale
      bill_1 = meal.bills.find_by(resident: resident_1)
      bill_2 = meal.bills.find_by(resident: resident_2)

      # bill_1 proportion: 2/8 = 0.25, capped: 0.25 * 5.00 = 1.25
      expect(bill_1.capped_amount).to eq(BigDecimal("2") / BigDecimal("8") * BigDecimal("5"))
      # bill_2 proportion: 6/8 = 0.75, capped: 0.75 * 5.00 = 3.75
      expect(bill_2.capped_amount).to eq(BigDecimal("6") / BigDecimal("8") * BigDecimal("5"))
    end

    it 'returns full amount when meal cost is under cap' do
      capped_community = FactoryBot.create(:community, cap: BigDecimal("25.00"))
      capped_unit = FactoryBot.create(:unit, community: capped_community)
      meal = FactoryBot.create(:meal, community: capped_community)
      resident = FactoryBot.create(:resident, community: capped_community, unit: capped_unit, multiplier: 2)

      FactoryBot.create(:meal_resident, meal: meal, resident: resident, community: capped_community)
      meal.reload

      # multiplier = 2, cap = 25.00, max_cost = 50.00
      # Bill of $10 is well under cap
      bill = FactoryBot.create(:bill, meal: meal, resident: resident, community: capped_community, amount: BigDecimal("10"))
      meal.reload

      expect(bill.capped_amount).to eq(BigDecimal("10"))
    end
  end
end
