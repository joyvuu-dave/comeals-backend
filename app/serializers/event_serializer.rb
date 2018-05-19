# == Schema Information
#
# Table name: events
#
#  id           :bigint(8)        not null, primary key
#  title        :string           not null
#  description  :string           default(""), not null
#  start_date   :datetime         not null
#  end_date     :datetime
#  allday       :boolean          default(FALSE), not null
#  community_id :bigint(8)        not null
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
  attributes :title,
             :description,
             :start,
             :url,
             :allDay

  def title
    if object.allday
      "ALL DAY\nEvent\n#{object.title}"
    else
      "\nEvent\n#{object.title}"
    end
  end

  def description
    "Event\n#{object.description}"
  end

  def start
    object.start_date
  end

  def url
    "#events/#{object.id}/edit"
  end

  def allDay
    object.allday
  end
end
