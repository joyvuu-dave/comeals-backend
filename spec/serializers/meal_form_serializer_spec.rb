# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MealFormSerializer do
  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }

  describe '#residents' do
    it 'includes active residents' do
      active_resident = create(:resident, community: community, unit: unit, active: true, multiplier: 2)
      meal = create(:meal, community: community)

      serializer = described_class.new(meal, scope: meal)
      resident_ids = serializer.residents.pluck(:id)

      expect(resident_ids).to include(active_resident.id)
    end

    it 'excludes inactive residents who did NOT attend' do
      inactive_nonattendee = create(:resident, community: community, unit: unit, active: false,
                                               multiplier: 2)
      meal = create(:meal, community: community)

      serializer = described_class.new(meal, scope: meal)
      resident_ids = serializer.residents.pluck(:id)

      expect(resident_ids).not_to include(inactive_nonattendee.id)
    end

    it 'includes inactive residents who DID attend (the bug fix)' do
      resident = create(:resident, community: community, unit: unit, active: true, multiplier: 2)
      meal = create(:meal, community: community)

      # Resident attends meal while active
      create(:meal_resident, meal: meal, resident: resident, community: community)

      # Resident is later deactivated (moved/died)
      resident.update!(active: false)

      serializer = described_class.new(meal, scope: meal)
      resident_ids = serializer.residents.pluck(:id)

      expect(resident_ids).to include(resident.id)
    end

    it 'does not duplicate residents who are active AND attending' do
      resident = create(:resident, community: community, unit: unit, active: true, multiplier: 2)
      meal = create(:meal, community: community)
      create(:meal_resident, meal: meal, resident: resident, community: community)

      serializer = described_class.new(meal, scope: meal)
      resident_ids = serializer.residents.pluck(:id)

      # Should appear exactly once, not duplicated by the OR
      expect(resident_ids.count(resident.id)).to eq(1)
    end
  end
end
