# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuperuserAdapter do
  let(:community) { create(:community) }

  describe '#authorized?' do
    it 'allows read access for all users' do
      admin = create(:admin_user, community: community, superuser: false)
      adapter = described_class.new(nil, admin)

      expect(adapter.authorized?(:read)).to be true
    end

    it 'allows create for superusers' do
      admin = create(:admin_user, community: community, superuser: true)
      adapter = described_class.new(nil, admin)

      expect(adapter.authorized?(:create)).to be true
      expect(adapter.authorized?(:new)).to be true
    end

    it 'denies create for non-superusers' do
      admin = create(:admin_user, community: community, superuser: false)
      adapter = described_class.new(nil, admin)

      expect(adapter.authorized?(:create)).to be false
      expect(adapter.authorized?(:new)).to be false
    end

    it 'allows update for superusers' do
      admin = create(:admin_user, community: community, superuser: true)
      adapter = described_class.new(nil, admin)

      expect(adapter.authorized?(:update)).to be true
      expect(adapter.authorized?(:edit)).to be true
    end

    it 'denies update for non-superusers' do
      admin = create(:admin_user, community: community, superuser: false)
      adapter = described_class.new(nil, admin)

      expect(adapter.authorized?(:update)).to be false
      expect(adapter.authorized?(:edit)).to be false
    end

    it 'allows destroy for superusers' do
      admin = create(:admin_user, community: community, superuser: true)
      adapter = described_class.new(nil, admin)

      expect(adapter.authorized?(:destroy)).to be true
    end

    it 'denies destroy for non-superusers' do
      admin = create(:admin_user, community: community, superuser: false)
      adapter = described_class.new(nil, admin)

      expect(adapter.authorized?(:destroy)).to be false
    end
  end
end
