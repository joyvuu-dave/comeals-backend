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

require 'rails_helper'

RSpec.describe Event, type: :model do
  before do
    allow(Pusher).to receive(:trigger)
  end

  describe "validations" do
    it "is valid with valid attributes" do
      event = FactoryBot.build(:event)
      expect(event).to be_valid
    end

    it "validates presence of title" do
      event = FactoryBot.build(:event, title: nil)
      expect(event).not_to be_valid
      expect(event.errors[:title]).to include("can't be blank")
    end

    it "validates presence of start_date" do
      event = FactoryBot.build(:event, start_date: nil, allday: true)
      expect(event).not_to be_valid
      expect(event.errors[:start_date]).to include("can't be blank")
    end
  end

  describe "#end_date_or_allday" do
    it "is invalid without end_date when allday is false" do
      event = FactoryBot.build(:event, end_date: nil, allday: false)
      expect(event).not_to be_valid
      expect(event.errors[:base]).to include("Event must end or be all day")
    end

    it "is valid without end_date when allday is true" do
      event = FactoryBot.build(:event, end_date: nil, allday: true)
      expect(event).to be_valid
    end

    it "is valid with end_date when allday is false" do
      event = FactoryBot.build(:event, start_date: 2.hours.ago, end_date: 1.hour.ago, allday: false)
      expect(event).to be_valid
    end
  end

  describe "#start_date_is_before_end_date" do
    it "is invalid when end_date is before start_date" do
      event = FactoryBot.build(:event, start_date: 1.hour.ago, end_date: 2.hours.ago, allday: false)
      expect(event).not_to be_valid
      expect(event.errors[:base]).to include("Start time must occur before end time")
    end

    it "is valid when start_date is before end_date" do
      event = FactoryBot.build(:event, start_date: 2.hours.ago, end_date: 1.hour.ago, allday: false)
      expect(event).to be_valid
    end

    it "skips validation when allday is true" do
      event = FactoryBot.build(:event, start_date: 1.hour.ago, end_date: 2.hours.ago, allday: true)
      expect(event).to be_valid
    end

    it "skips validation when end_date is blank" do
      event = FactoryBot.build(:event, start_date: 1.hour.ago, end_date: nil, allday: true)
      expect(event).to be_valid
    end
  end
end
