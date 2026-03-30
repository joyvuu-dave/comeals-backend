# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUser do
  let(:community) { create(:community) }

  describe '#superuser?' do
    it 'returns true when superuser is true' do
      admin = create(:admin_user, community: community, superuser: true)
      expect(admin.superuser?).to be true
    end

    it 'returns false when superuser is false' do
      admin = create(:admin_user, community: community, superuser: false)
      expect(admin.superuser?).to be false
    end
  end

  describe '#admin_users' do
    it 'returns admin users scoped to the same community' do
      admin1 = create(:admin_user, community: community)
      admin2 = create(:admin_user, community: community)
      other_community = create(:community)
      other_admin = create(:admin_user, community: other_community)

      result = admin1.admin_users
      expect(result).to include(admin1, admin2)
      expect(result).not_to include(other_admin)
    end
  end

  describe '#communities' do
    it 'returns only the admin user community' do
      admin = create(:admin_user, community: community)
      create(:community)

      expect(admin.communities).to eq([community])
    end
  end
end
