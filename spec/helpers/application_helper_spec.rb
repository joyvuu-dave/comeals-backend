# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }

  describe '#resident_name_helper' do
    it 'returns the full name when it has no last name' do
      create(:resident, community: community, unit: unit, name: 'Cher')
      expect(helper.resident_name_helper('Cher')).to eq('Cher')
    end

    it 'returns just the first name when it is unique' do
      create(:resident, community: community, unit: unit, name: 'Alice Smith')
      expect(helper.resident_name_helper('Alice Smith')).to eq('Alice')
    end

    it 'returns first name + last initial when first name is not unique' do
      create(:resident, community: community, unit: unit, name: 'Alice Smith')
      create(:resident, community: community, unit: unit, name: 'Alice Jones')
      expect(helper.resident_name_helper('Alice Smith')).to eq('Alice S')
      expect(helper.resident_name_helper('Alice Jones')).to eq('Alice J')
    end

    it 'uses full last name when initial is also ambiguous' do
      create(:resident, community: community, unit: unit, name: 'Alice Smith')
      create(:resident, community: community, unit: unit, name: 'Alice Springer')
      expect(helper.resident_name_helper('Alice Smith')).to eq('Alice Smith')
      expect(helper.resident_name_helper('Alice Springer')).to eq('Alice Springer')
    end

    it 'returns empty string for blank name' do
      expect(helper.resident_name_helper('')).to eq('')
      expect(helper.resident_name_helper(nil)).to eq('')
    end
  end

  describe '#category_helper' do
    it 'returns "Child" for multiplier 1' do
      expect(helper.category_helper(1)).to eq('Child')
    end

    it 'returns "Adult" for multiplier 2' do
      expect(helper.category_helper(2)).to eq('Adult')
    end

    it 'returns fractional adult for other multipliers' do
      expect(helper.category_helper(3)).to eq('1.5 Adult')
    end
  end

  describe '#parse_audit' do
    let(:resident) { create(:resident, community: community, unit: unit) }
    let(:meal) { create(:meal, community: community) }

    it 'parses meal create audit' do
      audit = meal.audits.first
      expect(helper.parse_audit(audit)).to eq('Meal record created')
    end

    it 'parses meal closed audit' do
      meal.update!(closed: true)
      audit = meal.audits.where(action: 'update').last
      expect(helper.parse_audit(audit)).to eq('Meal closed')
    end

    it 'parses meal opened audit' do
      meal.update!(closed: true)
      meal.update!(closed: false)
      audit = meal.audits.where(action: 'update').last
      expect(helper.parse_audit(audit)).to eq('Meal opened')
    end

    it 'parses description update audit' do
      meal.update!(description: 'Pasta night')
      audit = meal.audits.where(action: 'update').last
      expect(helper.parse_audit(audit)).to eq('Menu description updated')
    end

    it 'parses bill create audit' do
      bill = create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal('30'))
      audit = bill.audits.first
      result = helper.parse_audit(audit)
      expect(result).to include('added as cook')
    end

    it 'parses bill amount change audit' do
      bill = create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal('30'))
      bill.update!(amount: BigDecimal('50'))
      audit = bill.audits.where(action: 'update').last
      result = helper.parse_audit(audit)
      expect(result).to include('changed from')
      expect(result).to include('$30.00')
      expect(result).to include('$50.00')
    end

    it 'parses meal_resident create audit' do
      mr = create(:meal_resident, meal: meal, resident: resident, community: community)
      audit = mr.audits.first
      result = helper.parse_audit(audit)
      expect(result).to include('added')
    end

    it 'parses meal_resident marked late audit' do
      mr = create(:meal_resident, meal: meal, resident: resident, community: community, late: false)
      mr.update!(late: true)
      audit = mr.audits.where(action: 'update').last
      result = helper.parse_audit(audit)
      expect(result).to include('marked late')
    end

    it 'parses meal_resident vegetarian toggle audits' do
      mr = create(:meal_resident, meal: meal, resident: resident, community: community, vegetarian: false)
      mr.update!(vegetarian: true)
      audit = mr.audits.where(action: 'update').last
      result = helper.parse_audit(audit)
      expect(result).to include('marked veg')
      expect(result).not_to include('not veg')

      mr.update!(vegetarian: false)
      audit = mr.audits.where(action: 'update').last
      result = helper.parse_audit(audit)
      expect(result).to include('marked not veg')
    end

    it 'parses guest create audit' do
      guest = create(:guest, meal: meal, resident: resident, vegetarian: false)
      audit = guest.audits.first
      result = helper.parse_audit(audit)
      expect(result).to include('Omnivore guest')
      expect(result).to include('added')
    end

    it 'parses vegetarian guest create audit' do
      guest = create(:guest, meal: meal, resident: resident, vegetarian: true)
      audit = guest.audits.first
      result = helper.parse_audit(audit)
      expect(result).to include('Veg guest')
    end
  end
end
