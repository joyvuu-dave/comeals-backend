# == Schema Information
#
# Table name: events
#
#  id           :bigint           not null, primary key
#  allday       :boolean          default(FALSE), not null
#  description  :string           default(""), not null
#  end_date     :datetime
#  start_date   :datetime         not null
#  title        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#
# Indexes
#
#  index_events_on_community_id  (community_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#

FactoryBot.define do
  factory :event do
    title { "Maintenance Committee Meeting" }
    start_date { 49.hours.ago }
    end_date { 48.hours.ago }
    allday { false }
    community
  end
end
