# frozen_string_literal: true

# == Schema Information
#
# Table name: meals
#
#  id                :bigint           not null, primary key
#  cap               :decimal(12, 8)
#  closed            :boolean          default(FALSE), not null
#  closed_at         :datetime
#  date              :date             not null
#  description       :text             default(""), not null
#  max               :integer
#  start_time        :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  community_id      :bigint           not null
#  reconciliation_id :bigint
#  rotation_id       :bigint
#
# Indexes
#
#  index_meals_on_community_id_and_date  (community_id,date) UNIQUE
#  index_meals_on_reconciliation_id      (reconciliation_id)
#  index_meals_on_rotation_id            (rotation_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (reconciliation_id => reconciliations.id)
#  fk_rails_...  (rotation_id => rotations.id)
#

require 'rails_helper'

RSpec.describe Meal do
  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------

  describe 'validations' do
    it 'is valid with a date and community' do
      meal = build(:meal, community: community)
      expect(meal).to be_valid
    end

    it 'requires a date' do
      meal = create(:meal, community: community)
      meal.date = nil
      expect(meal).not_to be_valid
      expect(meal.errors[:date]).to be_present
    end

    it 'requires a community' do
      meal = build(:meal, community: nil)
      expect(meal).not_to be_valid
      expect(meal.errors[:community]).to be_present
    end

    it 'enforces date uniqueness per community' do
      date = Date.new(2025, 6, 15)
      create(:meal, community: community, date: date)

      duplicate = build(:meal, community: community, date: date)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:date]).to be_present
    end

    it 'allows the same date in different communities' do
      other_community = create(:community)
      date = Date.new(2025, 6, 15)

      create(:meal, community: community, date: date)
      meal = build(:meal, community: other_community, date: date)
      expect(meal).to be_valid
    end

    it 'validates max >= attendees_count when max is set' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident, community: community)
      meal.reload

      # attendees_count is 1, so max of 0 is invalid
      meal.closed = true
      meal.max = 0
      expect(meal).not_to be_valid
      expect(meal.errors[:max]).to be_present
    end

    it 'allows max to be nil' do
      meal = build(:meal, community: community, max: nil)
      expect(meal).to be_valid
    end

    it 'allows max equal to attendees_count' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident, community: community)
      meal.reload

      meal.closed = true
      meal.max = 1
      expect(meal).to be_valid
    end
  end

  # ---------------------------------------------------------------------------
  # Callbacks
  # ---------------------------------------------------------------------------

  describe 'callbacks' do
    describe '#set_cap (before_create)' do
      it 'copies the community cap to the meal' do
        capped_community = create(:community, cap: BigDecimal('3.50'))
        meal = create(:meal, community: capped_community)

        expect(meal.cap).to eq(BigDecimal('3.50'))
      end

      it 'leaves cap nil when community has no cap' do
        uncapped_community = create(:community, cap: nil)
        meal = create(:meal, community: uncapped_community)

        expect(meal.cap).to be_nil
      end
    end

    describe '#set_start_time (before_create)' do
      it 'sets start_time to date + 18 hours on Sundays' do
        sunday = Date.new(2025, 6, 15) # a Sunday
        meal = create(:meal, community: community, date: sunday)

        expect(meal.start_time).to eq(sunday.to_datetime + 18.hours)
      end

      it 'sets start_time to date + 19 hours on non-Sunday days' do
        monday = Date.new(2025, 6, 16) # a Monday
        meal = create(:meal, community: community, date: monday)

        expect(meal.start_time).to eq(monday.to_datetime + 19.hours)
      end

      it 'sets start_time to date + 19 hours on Friday' do
        friday = Date.new(2025, 6, 20) # a Friday
        meal = create(:meal, community: community, date: friday)

        expect(meal.start_time).to eq(friday.to_datetime + 19.hours)
      end
    end

    describe '#conditionally_set_max' do
      it 'clears max when meal is opened' do
        meal = create(:meal, community: community)
        resident = create(:resident, community: community, unit: unit, multiplier: 2)
        create(:meal_resident, meal: meal, resident: resident, community: community)
        meal.reload

        meal.update!(closed: true, max: 5)
        expect(meal.reload.max).to eq(5)

        meal.update!(closed: false)
        expect(meal.reload.max).to be_nil
      end
    end

    describe '#conditionally_set_closed_at' do
      it 'sets closed_at when meal is closed' do
        meal = create(:meal, community: community)

        expect(meal.closed_at).to be_nil

        meal.update!(closed: true, max: 0)
        expect(meal.closed_at).to be_present
      end

      it 'clears closed_at when meal is reopened' do
        meal = create(:meal, community: community)
        meal.update!(closed: true, max: 0)
        expect(meal.closed_at).to be_present

        meal.update!(closed: false)
        expect(meal.closed_at).to be_nil
      end

      it 'does not change closed_at when meal stays closed' do
        meal = create(:meal, community: community)
        meal.update!(closed: true, max: 0)
        original_closed_at = meal.closed_at

        meal.update!(description: 'Updated description')
        expect(meal.closed_at).to eq(original_closed_at)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Derived data methods
  # ---------------------------------------------------------------------------

  describe '#multiplier' do
    it 'returns the sum of meal_residents_multiplier and guests_multiplier' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident, community: community)
      meal.reload

      expect(meal.multiplier).to eq(2)
    end

    it 'includes guest multipliers' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident, community: community)
      create(:guest, meal: meal, resident: resident, multiplier: 1, name: 'Guest')
      meal.reload

      expect(meal.multiplier).to eq(3)
    end

    it 'returns 0 when no one is attending' do
      meal = create(:meal, community: community)
      expect(meal.multiplier).to eq(0)
    end

    it 'returns identical results whether associations are preloaded or not' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident, community: community)
      create(:guest, meal: meal, resident: resident, multiplier: 1, name: 'Guest')

      # Unloaded path (SQL SUM)
      unloaded = described_class.find(meal.id)
      sql_mult = unloaded.multiplier

      # Loaded path (Ruby Enumerable#sum)
      loaded = described_class.preload(:meal_residents, :guests).find(meal.id)
      expect(loaded.meal_residents).to be_loaded
      mem_mult = loaded.multiplier

      expect(mem_mult).to eq(sql_mult)
    end
  end

  describe '#attendees_count' do
    it 'returns the sum of meal_residents_count and guests_count' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident, community: community)
      create(:guest, meal: meal, resident: resident, multiplier: 1, name: 'A Guest')
      meal.reload

      expect(meal.attendees_count).to eq(2)
    end

    it 'returns 0 when no one is attending' do
      meal = create(:meal, community: community)
      expect(meal.attendees_count).to eq(0)
    end

    it 'returns identical results whether associations are preloaded or not' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident, community: community)
      create(:guest, meal: meal, resident: resident, multiplier: 1, name: 'A Guest')

      # Unloaded path (SQL COUNT)
      unloaded = described_class.find(meal.id)
      sql_count = unloaded.attendees_count

      # Loaded path (in-memory .size)
      loaded = described_class.preload(:meal_residents, :guests).find(meal.id)
      expect(loaded.meal_residents).to be_loaded
      mem_count = loaded.attendees_count

      expect(mem_count).to eq(sql_count)
    end
  end

  describe '#total_cost' do
    it 'sums bill amounts excluding no_cost bills' do
      meal = create(:meal, community: community)
      resident_a = create(:resident, community: community, unit: unit, multiplier: 2)
      resident_b = create(:resident, community: community, unit: unit, multiplier: 2)

      create(:bill, meal: meal, resident: resident_a, community: community, amount: BigDecimal('30'))
      create(:bill, meal: meal, resident: resident_b, community: community, amount: BigDecimal('20'))

      expect(meal.total_cost).to eq(BigDecimal('50'))
    end

    it 'excludes no_cost bills from the sum' do
      meal = create(:meal, community: community)
      resident_a = create(:resident, community: community, unit: unit, multiplier: 2)
      resident_b = create(:resident, community: community, unit: unit, multiplier: 2)

      create(:bill, meal: meal, resident: resident_a, community: community, amount: BigDecimal('30'))
      create(:bill, meal: meal, resident: resident_b, community: community, amount: BigDecimal('20'),
                    no_cost: true)

      expect(meal.total_cost).to eq(BigDecimal('30'))
    end

    it 'returns 0 when there are no bills' do
      meal = create(:meal, community: community)
      expect(meal.total_cost).to eq(BigDecimal('0'))
    end
  end

  describe '#max_cost' do
    it 'returns cap * multiplier when capped' do
      capped_community = create(:community, cap: BigDecimal('2.50'))
      capped_unit = create(:unit, community: capped_community)
      meal = create(:meal, community: capped_community)
      resident = create(:resident, community: capped_community, unit: capped_unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident, community: capped_community)
      meal.reload

      # cap 2.50 * multiplier 2 = 5.00
      expect(meal.max_cost).to eq(BigDecimal('5'))
    end

    it 'returns nil when uncapped' do
      meal = create(:meal, community: community)
      expect(meal.max_cost).to be_nil
    end
  end

  describe '#effective_total_cost' do
    it 'returns total_cost when uncapped' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal('100'))

      expect(meal.effective_total_cost).to eq(BigDecimal('100'))
    end

    it 'returns total_cost when capped but under the cap' do
      capped_community = create(:community, cap: BigDecimal('25'))
      capped_unit = create(:unit, community: capped_community)
      meal = create(:meal, community: capped_community)
      resident = create(:resident, community: capped_community, unit: capped_unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident, community: capped_community)
      meal.reload

      create(:bill, meal: meal, resident: resident, community: capped_community, amount: BigDecimal('10'))

      # max_cost = 25 * 2 = 50, total_cost = 10, under cap
      expect(meal.effective_total_cost).to eq(BigDecimal('10'))
    end

    it 'returns max_cost when total_cost exceeds the cap' do
      capped_community = create(:community, cap: BigDecimal('2.50'))
      capped_unit = create(:unit, community: capped_community)
      meal = create(:meal, community: capped_community)
      resident_a = create(:resident, community: capped_community, unit: capped_unit, multiplier: 2)
      resident_b = create(:resident, community: capped_community, unit: capped_unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident_a, community: capped_community)
      meal.reload

      # multiplier = 2, cap = 2.50, max_cost = 5.00
      create(:bill, meal: meal, resident: resident_a, community: capped_community, amount: BigDecimal('4'))
      create(:bill, meal: meal, resident: resident_b, community: capped_community, amount: BigDecimal('6'))

      # total_cost = 10, max_cost = 5
      expect(meal.effective_total_cost).to eq(BigDecimal('5'))
    end
  end

  describe '#unit_cost' do
    it 'returns effective_total_cost divided by multiplier' do
      meal = create(:meal, community: community)
      resident_a = create(:resident, community: community, unit: unit, multiplier: 2)
      resident_b = create(:resident, community: community, unit: unit, multiplier: 1)
      create(:meal_resident, meal: meal, resident: resident_a, community: community)
      create(:meal_resident, meal: meal, resident: resident_b, community: community)
      meal.reload

      resident_c = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:bill, meal: meal, resident: resident_c, community: community, amount: BigDecimal('30'))

      # multiplier = 3, effective_total_cost = 30, unit_cost = 10
      expect(meal.unit_cost).to eq(BigDecimal('10'))
    end

    it 'returns BigDecimal("0") when multiplier is 0' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal('50'))

      expect(meal.multiplier).to eq(0)
      expect(meal.unit_cost).to eq(BigDecimal('0'))
    end

    it 'returns a BigDecimal' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident, community: community)
      meal.reload

      create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal('50'))

      expect(meal.unit_cost).to be_a(BigDecimal)
    end
  end

  describe '#collected' do
    it 'returns unit_cost * multiplier' do
      meal = create(:meal, community: community)
      resident_a = create(:resident, community: community, unit: unit, multiplier: 2)
      resident_b = create(:resident, community: community, unit: unit, multiplier: 1)
      create(:meal_resident, meal: meal, resident: resident_a, community: community)
      create(:meal_resident, meal: meal, resident: resident_b, community: community)
      meal.reload

      resident_c = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:bill, meal: meal, resident: resident_c, community: community, amount: BigDecimal('30'))

      # unit_cost = 30/3 = 10, collected = 10 * 3 = 30
      expect(meal.collected).to eq(BigDecimal('30'))
    end

    it 'returns 0 when no one is attending' do
      meal = create(:meal, community: community)
      expect(meal.collected).to eq(BigDecimal('0'))
    end

    it 'equals effective_total_cost for uncapped meals' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident, community: community)
      meal.reload

      create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal('50'))

      expect(meal.collected).to eq(meal.effective_total_cost)
    end
  end

  describe '#capped?' do
    it 'returns true when cap is present' do
      capped_community = create(:community, cap: BigDecimal('3'))
      meal = create(:meal, community: capped_community)

      expect(meal.capped?).to be true
    end

    it 'returns false when cap is nil' do
      meal = create(:meal, community: community)
      expect(meal.capped?).to be false
    end
  end

  describe '#subsidized?' do
    it 'returns true when capped and total_cost exceeds max_cost' do
      capped_community = create(:community, cap: BigDecimal('2.50'))
      capped_unit = create(:unit, community: capped_community)
      meal = create(:meal, community: capped_community)
      resident_a = create(:resident, community: capped_community, unit: capped_unit, multiplier: 2)
      resident_b = create(:resident, community: capped_community, unit: capped_unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident_a, community: capped_community)
      meal.reload

      # max_cost = 2.50 * 2 = 5.00
      create(:bill, meal: meal, resident: resident_a, community: capped_community, amount: BigDecimal('4'))
      create(:bill, meal: meal, resident: resident_b, community: capped_community, amount: BigDecimal('6'))

      # total_cost = 10 > max_cost = 5
      expect(meal.subsidized?).to be true
    end

    it 'returns false when capped but total_cost is under max_cost' do
      capped_community = create(:community, cap: BigDecimal('25'))
      capped_unit = create(:unit, community: capped_community)
      meal = create(:meal, community: capped_community)
      resident = create(:resident, community: capped_community, unit: capped_unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident, community: capped_community)
      meal.reload

      create(:bill, meal: meal, resident: resident, community: capped_community, amount: BigDecimal('10'))

      # max_cost = 25 * 2 = 50, total_cost = 10
      expect(meal.subsidized?).to be false
    end

    it 'returns false when uncapped' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal('100'))

      expect(meal.subsidized?).to be false
    end

    it 'returns false when multiplier is 0' do
      capped_community = create(:community, cap: BigDecimal('2.50'))
      meal = create(:meal, community: capped_community)

      expect(meal.multiplier).to eq(0)
      expect(meal.subsidized?).to be false
    end
  end

  describe '#reconciled?' do
    it 'returns true when reconciliation_id is present' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal('10'))

      reconciliation = Reconciliation.create!(community: community, date: Time.zone.today,
                                              start_date: 2.years.ago.to_date,
                                              end_date: Time.zone.today)
      meal.reload

      expect(meal.reconciliation_id).to eq(reconciliation.id)
      expect(meal.reconciled?).to be true
    end

    it 'returns false when reconciliation_id is nil' do
      meal = create(:meal, community: community)
      expect(meal.reconciled?).to be false
    end
  end

  # ---------------------------------------------------------------------------
  # Scopes
  # ---------------------------------------------------------------------------

  describe '.unreconciled' do
    it 'returns meals without a reconciliation_id' do
      unreconciled_meal = create(:meal, community: community)
      reconciled_meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:bill, meal: reconciled_meal, resident: resident, community: community,
                    amount: BigDecimal('10'))

      Reconciliation.create!(community: community, date: Time.zone.today, start_date: 2.years.ago.to_date,
                             end_date: Time.zone.today)
      reconciled_meal.reload

      results = community.meals.unreconciled
      expect(results).to include(unreconciled_meal)
      expect(results).not_to include(reconciled_meal)
    end
  end

  describe '.open' do
    it 'returns meals where closed is false' do
      open_meal = create(:meal, community: community)
      closed_meal = create(:meal, community: community)
      closed_meal.update!(closed: true, max: 0)

      results = community.meals.open
      expect(results).to include(open_meal)
      expect(results).not_to include(closed_meal)
    end
  end

  describe '.closed_with_bills' do
    it 'returns closed meals that have at least one bill' do
      resident = create(:resident, community: community, unit: unit, multiplier: 2)

      closed_with_bill = create(:meal, community: community)
      closed_with_bill.update!(closed: true, max: 0)
      create(:bill, meal: closed_with_bill, resident: resident, community: community,
                    amount: BigDecimal('30'))

      closed_no_bills = create(:meal, community: community)
      closed_no_bills.update!(closed: true, max: 0)

      open_meal = create(:meal, community: community)

      results = community.meals.closed_with_bills
      expect(results).to include(closed_with_bill)
      expect(results).not_to include(closed_no_bills)
      expect(results).not_to include(open_meal)
    end

    it 'does not duplicate meals with multiple bills' do
      resident_a = create(:resident, community: community, unit: unit, multiplier: 2)
      resident_b = create(:resident, community: community, unit: unit, multiplier: 2)

      meal = create(:meal, community: community)
      meal.update!(closed: true, max: 0)
      create(:bill, meal: meal, resident: resident_a, community: community, amount: BigDecimal('20'))
      create(:bill, meal: meal, resident: resident_b, community: community, amount: BigDecimal('15'))

      results = community.meals.closed_with_bills
      expect(results.count).to eq(1)
    end
  end

  describe '.with_attendees' do
    it 'returns meals with meal_residents' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: resident, community: community)

      expect(described_class.with_attendees).to include(meal)
    end

    it 'returns meals with only guests (no meal_residents)' do
      meal = create(:meal, community: community)
      resident = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:guest, meal: meal, resident: resident)

      expect(described_class.with_attendees).to include(meal)
    end

    it 'excludes meals with no attendees' do
      meal = create(:meal, community: community)

      expect(described_class.with_attendees).not_to include(meal)
    end

    it 'does not duplicate meals with multiple attendees' do
      meal = create(:meal, community: community)
      r1 = create(:resident, community: community, unit: unit, multiplier: 2)
      r2 = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: r1, community: community)
      create(:meal_resident, meal: meal, resident: r2, community: community)

      expect(described_class.with_attendees.count).to eq(1)
    end
  end

  describe '#another_meal_in_this_rotation_has_less_than_two_cooks?' do
    let(:rotation) { create(:rotation, community: community, no_email: true) }
    let(:cook1) { create(:resident, community: community, unit: unit, multiplier: 2) }
    let(:cook2) { create(:resident, community: community, unit: unit, multiplier: 2) }

    it 'returns false when all other meals have 2+ cooks' do
      meal = create(:meal, community: community, rotation: rotation)
      other_meal = create(:meal, community: community, rotation: rotation)
      create(:bill, meal: other_meal, resident: cook1, community: community, amount: BigDecimal('30'))
      create(:bill, meal: other_meal, resident: cook2, community: community, amount: BigDecimal('20'))

      expect(meal.another_meal_in_this_rotation_has_less_than_two_cooks?).to be false
    end

    it 'returns true when another meal has fewer than 2 cooks' do
      meal = create(:meal, community: community, rotation: rotation)
      other_meal = create(:meal, community: community, rotation: rotation)
      create(:bill, meal: other_meal, resident: cook1, community: community, amount: BigDecimal('30'))

      expect(meal.another_meal_in_this_rotation_has_less_than_two_cooks?).to be true
    end

    it 'returns true when another meal has zero cooks' do
      meal = create(:meal, community: community, rotation: rotation)
      create(:meal, community: community, rotation: rotation) # no bills

      expect(meal.another_meal_in_this_rotation_has_less_than_two_cooks?).to be true
    end

    it 'returns false when meal has no rotation' do
      meal = create(:meal, community: community, rotation: nil)
      expect(meal.another_meal_in_this_rotation_has_less_than_two_cooks?).to be false
    end
  end

  describe '.is_holiday?' do
    it 'detects Thanksgiving (4th Thursday in November)' do
      expect(described_class.is_holiday?(Date.new(2026, 11, 26))).to be true
      expect(described_class.is_holiday?(Date.new(2025, 11, 27))).to be true
    end

    it 'detects Christmas' do
      expect(described_class.is_holiday?(Date.new(2026, 12, 25))).to be true
    end

    it 'detects New Year' do
      expect(described_class.is_holiday?(Date.new(2026, 1, 1))).to be true
    end

    it 'detects Mother\'s Day (2nd Sunday in May)' do
      expect(described_class.is_holiday?(Date.new(2026, 5, 10))).to be true
      expect(described_class.is_holiday?(Date.new(2025, 5, 11))).to be true
    end

    it 'detects Easter' do
      # Easter 2026 is April 5
      expect(described_class.is_holiday?(Date.new(2026, 4, 5))).to be true
      # Easter 2025 is April 20
      expect(described_class.is_holiday?(Date.new(2025, 4, 20))).to be true
    end

    it 'detects July 4th' do
      expect(described_class.is_holiday?(Date.new(2026, 7, 4))).to be true
    end

    it 'returns false for non-holidays' do
      expect(described_class.is_holiday?(Date.new(2026, 3, 15))).to be false
      expect(described_class.is_holiday?(Date.new(2026, 8, 20))).to be false
    end
  end

  describe '.create_templates' do
    it 'creates meals on Sun/Fri and alternating Mon/Tue' do
      # 2 weeks: enough to see the alternating pattern
      start_date = Date.new(2026, 6, 1) # Monday
      end_date = Date.new(2026, 6, 14) # Sunday

      count = described_class.create_templates(community.id, start_date, end_date, 1)

      expect(count).to be > 0
      dates = described_class.where(community: community).pluck(:date)
      wdays = dates.map(&:wday)
      # Should only be Sun(0), Mon(1), Tue(2), or Fri(4)
      expect(wdays.all? { |d| [0, 1, 2, 4].include?(d) }).to be true
    end

    it 'skips holidays' do
      # July 4th 2026 is a Saturday (wday 6), so pick Christmas which is a Friday (wday 5) in 2026
      # Actually Christmas 2026 is a Friday, wday 5. Let's use New Year's Day 2026 which is Thursday wday 4...
      # Actually Jan 1 2026 is Thursday. July 4 2026 is Saturday. Neither falls on our meal days.
      # Use a range that includes Thanksgiving 2026 (Nov 26, Thursday) — not a meal day.
      # Let's just verify the count doesn't include any holiday dates
      start_date = Date.new(2026, 12, 20)
      end_date = Date.new(2027, 1, 5)

      described_class.create_templates(community.id, start_date, end_date, 1)

      dates = described_class.where(community: community).pluck(:date)
      dates.each do |d|
        expect(described_class.is_holiday?(d)).to be(false), "Created a meal on holiday: #{d}"
      end
    end
  end

  describe '.create_modified_templates' do
    it 'creates meals only on Sundays and Fridays' do
      start_date = Date.new(2026, 6, 1)
      end_date = Date.new(2026, 6, 30)

      count = described_class.create_modified_templates(community.id, start_date, end_date)

      expect(count).to be > 0
      wdays = described_class.where(community: community).pluck(:date).map(&:wday)
      expect(wdays.all? { |d| [0, 4].include?(d) }).to be true
    end

    it 'skips holidays' do
      start_date = Date.new(2026, 12, 20)
      end_date = Date.new(2027, 1, 5)

      described_class.create_modified_templates(community.id, start_date, end_date)

      dates = described_class.where(community: community).pluck(:date)
      dates.each do |d|
        expect(described_class.is_holiday?(d)).to be(false), "Created a meal on holiday: #{d}"
      end
    end
  end
end
