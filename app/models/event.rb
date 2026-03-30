# frozen_string_literal: true

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

class Event < ApplicationRecord
  belongs_to :community

  validates :title, presence: true
  validates :start_date, presence: true

  validate :end_date_or_allday
  validate :start_date_is_before_end_date

  after_commit :trigger_pusher

  def end_date_or_allday
    return if end_date.present? || allday

    errors.add(:base, 'Event must end or be all day')
  end

  def start_date_is_before_end_date
    return if allday || end_date.blank?

    errors.add(:base, 'Start time must occur before end time') if end_date < start_date
  end

  def trigger_pusher
    community.trigger_pusher(start_date)
  end
end
