# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_users
#
#  id                     :bigint           not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  superuser              :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  community_id           :bigint           not null
#
# Indexes
#
#  index_admin_users_on_community_id          (community_id)
#  index_admin_users_on_email                 (email) UNIQUE
#  index_admin_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#
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
