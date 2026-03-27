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

RSpec.describe GuestRoomReservation, type: :model do
  before do
    allow(Pusher).to receive(:trigger)
  end

  describe "validations" do
    it "is valid with valid attributes" do
      reservation = FactoryBot.build(:guest_room_reservation)
      expect(reservation).to be_valid
    end

    it "validates presence of resident" do
      reservation = FactoryBot.build(:guest_room_reservation, resident: nil)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:resident]).to include("must exist")
    end

    it "validates presence of date" do
      reservation = FactoryBot.build(:guest_room_reservation, date: nil)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:date]).to include("can't be blank")
    end
  end

  describe "uniqueness of date per community" do
    it "is invalid when date is already taken for the same community" do
      community = FactoryBot.create(:community)
      resident = FactoryBot.create(:resident, community: community)
      FactoryBot.create(:guest_room_reservation,
        community: community,
        resident: resident,
        date: Date.new(2026, 4, 1)
      )

      duplicate = FactoryBot.build(:guest_room_reservation,
        community: community,
        resident: resident,
        date: Date.new(2026, 4, 1)
      )
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:date]).to include("has already been taken")
    end

    it "is valid when the same date is used in a different community" do
      community1 = FactoryBot.create(:community)
      community2 = FactoryBot.create(:community)
      resident1 = FactoryBot.create(:resident, community: community1)
      resident2 = FactoryBot.create(:resident, community: community2)
      FactoryBot.create(:guest_room_reservation,
        community: community1,
        resident: resident1,
        date: Date.new(2026, 4, 1)
      )

      reservation = FactoryBot.build(:guest_room_reservation,
        community: community2,
        resident: resident2,
        date: Date.new(2026, 4, 1)
      )
      expect(reservation).to be_valid
    end
  end
end
