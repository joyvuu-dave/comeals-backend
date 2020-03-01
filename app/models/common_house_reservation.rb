# == Schema Information
#
# Table name: common_house_reservations
#
#  id           :bigint           not null, primary key
#  end_date     :datetime         not null
#  start_date   :datetime         not null
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#  resident_id  :bigint           not null
#
# Indexes
#
#  index_common_house_reservations_on_community_id  (community_id)
#  index_common_house_reservations_on_resident_id   (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (resident_id => residents.id)
#

class CommonHouseReservation < ApplicationRecord
  belongs_to :community
  belongs_to :resident

  validates_presence_of :resident
  validates_presence_of :start_date
  validates_presence_of :end_date

  validate :period_is_free
  validate :start_date_is_before_end_date

  after_commit :trigger_pusher

  def period_is_free
    errors.add(:base, "Time period is already taken") if CommonHouseReservation
                                                            .where(community_id: community_id)
                                                            .where.not(id: id)
                                                            .where("start_date < ?", end_date)
                                                            .where("end_date > ?", start_date)
                                                            .exists?
  end

  def start_date_is_before_end_date
    errors.add(:base, "Start time must occur before end time") if end_date < start_date
  end

  def trigger_pusher
    community.trigger_pusher(self.start_date)
  end

end
