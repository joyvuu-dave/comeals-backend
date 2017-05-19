# == Schema Information
#
# Table name: community_managers
#
#  id           :integer          not null, primary key
#  community_id :integer
#  manager_id   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_community_managers_on_community_id  (community_id)
#  index_community_managers_on_manager_id    (manager_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (manager_id => managers.id)
#

class CommunityManager < ApplicationRecord
  belongs_to :community
  belongs_to :manager
end
