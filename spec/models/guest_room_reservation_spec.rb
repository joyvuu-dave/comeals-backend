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

require 'rails_helper'

RSpec.describe GuestRoomReservation do
  before do
    allow(Pusher).to receive(:trigger)
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      reservation = build(:guest_room_reservation)
      expect(reservation).to be_valid
    end

    it 'validates presence of resident' do
      reservation = build(:guest_room_reservation, resident: nil)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:resident]).to include('must exist')
    end

    it 'validates presence of date' do
      reservation = build(:guest_room_reservation, date: nil)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:date]).to include("can't be blank")
    end
  end

  describe 'uniqueness of date per community' do
    it 'is invalid when date is already taken for the same community' do
      community = create(:community)
      resident = create(:resident, community: community)
      create(:guest_room_reservation,
             community: community,
             resident: resident,
             date: Date.new(2026, 4, 1))

      duplicate = build(:guest_room_reservation,
                        community: community,
                        resident: resident,
                        date: Date.new(2026, 4, 1))
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:date]).to include('has already been taken')
    end

    it 'is valid when the same date is used in a different community' do
      community1 = create(:community)
      community2 = create(:community)
      resident1 = create(:resident, community: community1)
      resident2 = create(:resident, community: community2)
      create(:guest_room_reservation,
             community: community1,
             resident: resident1,
             date: Date.new(2026, 4, 1))

      reservation = build(:guest_room_reservation,
                          community: community2,
                          resident: resident2,
                          date: Date.new(2026, 4, 1))
      expect(reservation).to be_valid
    end
  end
end
