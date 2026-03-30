# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Key do
  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }

  describe '#set_token' do
    it 'generates a unique token on creation' do
      resident = create(:resident, community: community, unit: unit)
      key = resident.key

      expect(key.token).to be_present
      expect(key.token.length).to be > 20
    end

    it 'generates unique tokens across keys' do
      r1 = create(:resident, community: community, unit: unit)
      r2 = create(:resident, community: community, unit: unit)

      expect(r1.key.token).not_to eq(r2.key.token)
    end
  end

  describe 'associations' do
    it 'is polymorphic — belongs to identity' do
      resident = create(:resident, community: community, unit: unit)
      key = resident.key

      expect(key.identity_type).to eq('Resident')
      expect(key.identity).to eq(resident)
    end
  end
end
