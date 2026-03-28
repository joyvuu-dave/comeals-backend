# == Schema Information
#
# Table name: rotations
#
#  id                 :bigint           not null, primary key
#  color              :string           not null
#  description        :string           default(""), not null
#  place_value        :integer
#  residents_notified :boolean          default(FALSE), not null
#  start_date         :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  community_id       :bigint           not null
#
# Indexes
#
#  index_rotations_on_community_id  (community_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#
FactoryBot.define do
  factory :rotation do
    community
    color { "blue" }
    no_email { true }
  end
end
