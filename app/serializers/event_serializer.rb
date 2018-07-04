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
  attributes :id,
             :type,
             :title,
             :description,
             :start,
             :end,
             :url,
             :allDay,
             :color

  def id
    object.cache_key_with_version
  end

  def type
    object.class.to_s
  end

  def title
    if object.allday
      "ALL DAY\nEvent\n#{object.title}"
    else
      "#{object.start_date.strftime('%l:%M%P')} - #{object.end_date.strftime('%l:%M%P')}\nEvent\n#{object.title}"
    end
  end

  def description
    "Event\n#{object.description}"
  end

  def start
    object.start_date
  end

  def end
    object.allday ? object.start_date : object.end_date
  end

  def url
    "events/edit/#{object.id}"
  end

  def allDay
    object.allday
  end

  def color
    "#7ebc35"
  end

end
