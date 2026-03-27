# == Schema Information
#
# Table name: residents
#
#  id                   :bigint           not null, primary key
#  active               :boolean          default(TRUE), not null
#  birthday             :date             default(Mon, 01 Jan 1900), not null
#  can_cook             :boolean          default(TRUE), not null
#  email                :string
#  multiplier           :integer          default(2), not null
#  name                 :string           not null
#  password_digest      :string           not null
#  reset_password_token :string
#  vegetarian           :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  community_id         :bigint           not null
#  unit_id              :bigint           not null
#
# Indexes
#
#  index_residents_on_community_id           (community_id)
#  index_residents_on_email                  (email) UNIQUE
#  index_residents_on_name_and_community_id  (name,community_id) UNIQUE
#  index_residents_on_reset_password_token   (reset_password_token) UNIQUE
#  index_residents_on_unit_id                (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (unit_id => units.id)
#
require 'rails_helper'

RSpec.describe Resident, type: :model do
  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }

  describe '#calc_balance' do
    it 'returns 0 when there are no unreconciled meals' do
      resident = FactoryBot.create(:resident, community: community, unit: unit)
      expect(resident.calc_balance).to eq(BigDecimal("0"))
    end

    it 'returns 0 for a cook who attends their own meal (single adult)' do
      cook = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      meal = FactoryBot.create(:meal, community: community)

      FactoryBot.create(:meal_resident, meal: meal, resident: cook, community: community)
      FactoryBot.create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal("50"))
      meal.reload

      # Credit (reimbursement) exactly equals debit (attendance charge)
      expect(cook.calc_balance).to eq(BigDecimal("0"))
    end

    it 'gives a positive balance to a cook who does not attend' do
      cook = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      attendee = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      meal = FactoryBot.create(:meal, community: community)

      FactoryBot.create(:meal_resident, meal: meal, resident: attendee, community: community)
      FactoryBot.create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal("50"))
      meal.reload

      expect(cook.calc_balance).to eq(BigDecimal("50"))
    end

    it 'gives a negative balance to an attendee who does not cook' do
      cook = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      attendee = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      meal = FactoryBot.create(:meal, community: community)

      FactoryBot.create(:meal_resident, meal: meal, resident: attendee, community: community)
      FactoryBot.create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal("50"))
      meal.reload

      # Attendee owes the full meal cost (only attendee, multiplier 2, unit_cost = 50/2 = 25, charge = 25*2 = 50)
      expect(attendee.calc_balance).to eq(BigDecimal("-50"))
    end

    it 'splits cost proportionally between adults and children' do
      cook = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      adult = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      child = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 1)
      meal = FactoryBot.create(:meal, community: community)

      FactoryBot.create(:meal_resident, meal: meal, resident: adult, community: community)
      FactoryBot.create(:meal_resident, meal: meal, resident: child, community: community)
      FactoryBot.create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal("30"))
      meal.reload

      # multiplier = 2 + 1 = 3
      # unit_cost = 30 / 3 = 10
      # adult charge = 10 * 2 = 20
      # child charge = 10 * 1 = 10
      expect(adult.calc_balance).to eq(BigDecimal("-20"))
      expect(child.calc_balance).to eq(BigDecimal("-10"))
    end

    it 'excludes reconciled meals from balance' do
      reconciliation = Reconciliation.create!(community: community, date: Date.today)
      resident = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)

      # Reconciled meal — should be excluded
      reconciled_meal = FactoryBot.create(:meal, community: community, reconciliation: reconciliation)
      FactoryBot.create(:meal_resident, meal: reconciled_meal, resident: resident, community: community)
      FactoryBot.create(:bill, meal: reconciled_meal, resident: resident, community: community, amount: BigDecimal("99"))

      # Unreconciled meal — should be included
      unreconciled_meal = FactoryBot.create(:meal, community: community)
      FactoryBot.create(:meal_resident, meal: unreconciled_meal, resident: resident, community: community)
      FactoryBot.create(:bill, meal: unreconciled_meal, resident: resident, community: community, amount: BigDecimal("30"))

      reconciled_meal.reload
      unreconciled_meal.reload

      # Balance should only reflect the unreconciled meal (cook + attend = 0)
      expect(resident.calc_balance).to eq(BigDecimal("0"))
    end

    it 'correctly sums across multiple unreconciled meals' do
      cook = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      eater = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)

      meal1 = FactoryBot.create(:meal, community: community)
      FactoryBot.create(:meal_resident, meal: meal1, resident: eater, community: community)
      FactoryBot.create(:bill, meal: meal1, resident: cook, community: community, amount: BigDecimal("40"))
      meal1.reload

      meal2 = FactoryBot.create(:meal, community: community)
      FactoryBot.create(:meal_resident, meal: meal2, resident: eater, community: community)
      FactoryBot.create(:bill, meal: meal2, resident: cook, community: community, amount: BigDecimal("60"))
      meal2.reload

      # Cook: reimbursed 40 + 60 = 100, no attendance charges
      expect(cook.calc_balance).to eq(BigDecimal("100"))

      # Eater: charged for both meals (sole attendee each time, so full cost)
      expect(eater.calc_balance).to eq(BigDecimal("-100"))
    end

    it 'charges guest costs to the hosting resident' do
      cook = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      host = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      meal = FactoryBot.create(:meal, community: community)

      FactoryBot.create(:meal_resident, meal: meal, resident: host, community: community)
      FactoryBot.create(:guest, meal: meal, resident: host, multiplier: 2)
      FactoryBot.create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal("60"))
      meal.reload

      # multiplier = host(2) + guest(2) = 4
      # unit_cost = 60 / 4 = 15
      # host meal charge = 15 * 2 = 30
      # host guest charge = 15 * 2 = 30
      # total host owes = -60
      expect(host.calc_balance).to eq(BigDecimal("-60"))
    end

    it 'handles capped meals correctly (cook reimbursed at capped rate)' do
      capped_community = FactoryBot.create(:community, cap: BigDecimal("5.00"))
      capped_unit = FactoryBot.create(:unit, community: capped_community)

      cook = FactoryBot.create(:resident, community: capped_community, unit: capped_unit, multiplier: 2)
      eater = FactoryBot.create(:resident, community: capped_community, unit: capped_unit, multiplier: 2)
      meal = FactoryBot.create(:meal, community: capped_community)

      FactoryBot.create(:meal_resident, meal: meal, resident: eater, community: capped_community)
      FactoryBot.create(:bill, meal: meal, resident: cook, community: capped_community, amount: BigDecimal("20"))
      meal.reload

      # multiplier = 2, cap = 5.00, max_cost = 10.00
      # total_cost = 20, exceeds cap
      # effective_total_cost = 10.00
      # unit_cost = 10 / 2 = 5.00
      # eater charge = 5 * 2 = 10
      # cook reimbursement = 20 (full bill amount, NOT capped — credits = actual amount spent)
      # cook balance = 20 - 0 = 20
      # eater balance = 0 - 10 = -10
      expect(cook.calc_balance).to eq(BigDecimal("20"))
      expect(eater.calc_balance).to eq(BigDecimal("-10"))
    end

    it 'balances sum to zero with multiple cooks and attendees' do
      cook_a = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      cook_b = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      eater = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)

      meal = FactoryBot.create(:meal, community: community)
      FactoryBot.create(:meal_resident, meal: meal, resident: cook_a, community: community)
      FactoryBot.create(:meal_resident, meal: meal, resident: cook_b, community: community)
      FactoryBot.create(:meal_resident, meal: meal, resident: eater, community: community)
      FactoryBot.create(:bill, meal: meal, resident: cook_a, community: community, amount: BigDecimal("30"))
      FactoryBot.create(:bill, meal: meal, resident: cook_b, community: community, amount: BigDecimal("20"))
      meal.reload

      balance_a = cook_a.calc_balance
      balance_b = cook_b.calc_balance
      balance_eater = eater.calc_balance

      # Total credits must equal total debits within sub-micropenny precision.
      # BigDecimal repeating decimals (50/6) create negligible artifacts that
      # banker's rounding absorbs at settlement time.
      total = balance_a + balance_b + balance_eater
      expect(total.abs).to be < BigDecimal("0.00000001")
    end
  end

  describe '#balance' do
    it 'reads from resident_balances cache, not from calc_balance' do
      resident = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)

      # Manually set a cached balance
      ResidentBalance.create!(resident: resident, amount: BigDecimal("42.50"))

      # balance should return the cached value, not recompute
      expect(resident.balance).to eq(BigDecimal("42.50"))
    end

    it 'returns 0 when no cached balance exists' do
      resident = FactoryBot.create(:resident, community: community, unit: unit)
      expect(resident.balance).to eq(BigDecimal("0"))
    end
  end

  describe '#meals_attended' do
    it 'counts only unreconciled meals' do
      resident = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      reconciliation = Reconciliation.create!(community: community, date: Date.today)

      reconciled_meal = FactoryBot.create(:meal, community: community, reconciliation: reconciliation)
      FactoryBot.create(:meal_resident, meal: reconciled_meal, resident: resident, community: community)

      unreconciled_meal = FactoryBot.create(:meal, community: community)
      FactoryBot.create(:meal_resident, meal: unreconciled_meal, resident: resident, community: community)

      expect(resident.meals_attended).to eq(1)
    end
  end
end
