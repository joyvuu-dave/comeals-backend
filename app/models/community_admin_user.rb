# == Schema Information
#
# Table name: community_admin_users
#
#  id            :integer          not null, primary key
#  community_id  :integer
#  admin_user_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_community_admin_users_on_admin_user_id  (admin_user_id)
#  index_community_admin_users_on_community_id   (community_id)
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#  fk_rails_...  (community_id => communities.id)
#

class CommunityAdminUser < ApplicationRecord
  belongs_to :community
  belongs_to :admin_user
end
