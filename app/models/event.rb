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

class Event < ApplicationRecord
  belongs_to :community

  validates_presence_of :title
  validates_presence_of :start_date

  validate :end_date_or_allday
  validate :start_date_is_before_end_date

  after_commit :trigger_pusher

  def end_date_or_allday
    unless end_date.present? || allday
      errors.add(:base, "Event must end or be all day")
    end
  end

  def start_date_is_before_end_date
    unless allday || end_date.blank?
      errors.add(:base, "Start time must occur before end time") if end_date < start_date
    end
  end

  def trigger_pusher
    community.trigger_pusher(self.start_date)
  end
end
