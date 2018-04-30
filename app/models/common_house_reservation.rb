# == Schema Information
#
# Table name: common_house_reservations
#
#  id           :bigint(8)        not null, primary key
#  community_id :bigint(8)        not null
#  resident_id  :bigint(8)        not null
#  start_date   :datetime         not null
#  end_date     :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  title        :string
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

  def period_is_free
    errors.add(:base, "Time period is already taken") if CommonHouseReservation
                                                            .where(community_id: community_id)
                                                            .where.not(id: id)
                                                            .where("start_date <= ?", end_date)
                                                            .where("end_date >= ?", start_date)
                                                            .exists?
  end
end
