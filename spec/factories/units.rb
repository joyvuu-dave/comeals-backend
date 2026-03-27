# == Schema Information
#
# Table name: units
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  community_id    :bigint           not null
#  residents_count :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryBot.define do
  factory :unit do
    community
    name { ("A".."Z").to_a.sample }
  end
end
