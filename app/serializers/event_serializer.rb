# == Schema Information
#
# Table name: events
#
#  id           :integer          not null, primary key
#  title        :string           not null
#  description  :string           default(""), not null
#  start_date   :datetime         not null
#  end_date     :datetime
#  allday       :boolean          default(FALSE), not null
#  community_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_events_on_community_id  (community_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#

class EventSerializer < ActiveModel::Serializer

  cache key: 'event'
  attributes :title,
             :start,
             :url,
             :description

  def start
    object.start_date
  end

  def url
    "/events/#{object.id}/edit"
  end
end
