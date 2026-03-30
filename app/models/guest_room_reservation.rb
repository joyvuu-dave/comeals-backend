# frozen_string_literal: true

# == Schema Information
#
# Table name: guest_room_reservations
#
#  id           :bigint           not null, primary key
#  date         :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#  resident_id  :bigint           not null
#
# Indexes
#
#  index_guest_room_reservations_on_community_id  (community_id)
#  index_guest_room_reservations_on_resident_id   (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (resident_id => residents.id)
#

class GuestRoomReservation < ApplicationRecord
  # Ransack allowlists for ActiveAdmin sorting
  def self.ransackable_attributes(_auth_object = nil)
    %w[id community_id created_at date resident_id updated_at]
  end

  belongs_to :community
  belongs_to :resident

  validates :date, presence: true
  validates :date, uniqueness: { scope: :community_id } # rubocop:disable Rails/UniqueValidationWithoutIndex -- enforced at application level

  after_commit :trigger_pusher

  def trigger_pusher
    community.trigger_pusher(date)
  end
end
