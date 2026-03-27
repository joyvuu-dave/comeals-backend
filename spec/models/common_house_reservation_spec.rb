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

require 'rails_helper'

RSpec.describe CommonHouseReservation, type: :model do
  before do
    allow(Pusher).to receive(:trigger)
  end

  describe "validations" do
    it "is valid with valid attributes" do
      reservation = FactoryBot.build(:common_house_reservation)
      expect(reservation).to be_valid
    end

    it "validates presence of resident" do
      reservation = FactoryBot.build(:common_house_reservation, resident: nil)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:resident]).to include("must exist")
    end

    it "validates presence of start_date" do
      reservation = FactoryBot.build(:common_house_reservation, start_date: nil)
      allow(reservation).to receive(:start_date_is_before_end_date)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:start_date]).to include("can't be blank")
    end

    it "validates presence of end_date" do
      reservation = FactoryBot.build(:common_house_reservation, end_date: nil)
      allow(reservation).to receive(:start_date_is_before_end_date)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:end_date]).to include("can't be blank")
    end
  end

  describe "#period_is_free" do
    it "is invalid when overlapping with an existing reservation in the same community" do
      community = FactoryBot.create(:community)
      resident = FactoryBot.create(:resident, community: community)
      FactoryBot.create(:common_house_reservation,
        community: community,
        resident: resident,
        start_date: 10.hours.ago,
        end_date: 8.hours.ago
      )

      overlapping = FactoryBot.build(:common_house_reservation,
        community: community,
        resident: resident,
        start_date: 9.hours.ago,
        end_date: 7.hours.ago
      )
      expect(overlapping).not_to be_valid
      expect(overlapping.errors[:base]).to include("Time period is already taken")
    end

    it "is valid when not overlapping with existing reservations" do
      community = FactoryBot.create(:community)
      resident = FactoryBot.create(:resident, community: community)
      FactoryBot.create(:common_house_reservation,
        community: community,
        resident: resident,
        start_date: 10.hours.ago,
        end_date: 8.hours.ago
      )

      non_overlapping = FactoryBot.build(:common_house_reservation,
        community: community,
        resident: resident,
        start_date: 7.hours.ago,
        end_date: 6.hours.ago
      )
      expect(non_overlapping).to be_valid
    end

    it "is valid when overlapping reservation is in a different community" do
      community1 = FactoryBot.create(:community)
      community2 = FactoryBot.create(:community)
      resident1 = FactoryBot.create(:resident, community: community1)
      resident2 = FactoryBot.create(:resident, community: community2)
      FactoryBot.create(:common_house_reservation,
        community: community1,
        resident: resident1,
        start_date: 10.hours.ago,
        end_date: 8.hours.ago
      )

      reservation = FactoryBot.build(:common_house_reservation,
        community: community2,
        resident: resident2,
        start_date: 9.hours.ago,
        end_date: 7.hours.ago
      )
      expect(reservation).to be_valid
    end
  end

  describe "#start_date_is_before_end_date" do
    it "is invalid when end_date is before start_date" do
      reservation = FactoryBot.build(:common_house_reservation, start_date: 1.hour.ago, end_date: 2.hours.ago)
      expect(reservation).not_to be_valid
      expect(reservation.errors[:base]).to include("Start time must occur before end time")
    end

    it "is valid when start_date is before end_date" do
      reservation = FactoryBot.build(:common_house_reservation, start_date: 2.hours.ago, end_date: 1.hour.ago)
      expect(reservation).to be_valid
    end
  end
end
