# == Schema Information
#
# Table name: units
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  community_id    :integer          not null
#  residents_count :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_units_on_community_id           (community_id)
#  index_units_on_community_id_and_name  (community_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#

FactoryGirl.define do
  factory :unit do
    community
    name { ("A".."Z").to_a.sample }
  end
end
