require 'rails_helper'

RSpec.describe CalendarSerializer, type: :serializer do
  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }
  let(:resident) { FactoryBot.create(:resident, community: community, unit: unit, birthday: Date.new(1990, 4, 15)) }

  let(:start_date) { "2026-04-01" }
  let(:end_date) { "2026-04-30" }
  let(:options) do
    {
      month: 4, year: 2026,
      start_date: start_date, end_date: end_date,
      month_int_array: [4],
      serializer: CalendarSerializer
    }
  end

  before do
    allow(Pusher).to receive(:trigger)
  end

  def serialize
    ActiveModelSerializers::SerializableResource.new(community, options).as_json
  end

  describe 'top-level attributes' do
    it 'includes month and year' do
      result = serialize
      expect(result[:month]).to eq(4)
      expect(result[:year]).to eq(2026)
    end
  end

  describe 'meals' do
    it 'includes meals within the date range' do
      in_range = FactoryBot.create(:meal, community: community, date: Date.new(2026, 4, 10))
      out_range = FactoryBot.create(:meal, community: community, date: Date.new(2026, 6, 10))

      result = serialize
      meal_dates = result[:meals].map { |m| m[:start].to_date }
      expect(meal_dates).to include(Date.new(2026, 4, 10))
      expect(meal_dates).not_to include(Date.new(2026, 6, 10))
    end
  end

  describe 'bills' do
    it 'includes bills for meals within the date range' do
      meal = FactoryBot.create(:meal, community: community, date: Date.new(2026, 4, 15))
      cook = FactoryBot.create(:resident, community: community, unit: unit)
      FactoryBot.create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal("50"))

      result = serialize
      expect(result[:bills].length).to eq(1)
    end
  end

  describe 'rotations' do
    it 'includes rotations that have meals in the date range' do
      rotation = FactoryBot.create(:rotation, community: community)
      FactoryBot.create(:meal, community: community, rotation: rotation, date: Date.new(2026, 4, 5))

      result = serialize
      expect(result[:rotations].length).to eq(1)
    end

    it 'excludes rotations with no meals in the range' do
      rotation = FactoryBot.create(:rotation, community: community)
      FactoryBot.create(:meal, community: community, rotation: rotation, date: Date.new(2026, 8, 1))

      result = serialize
      expect(result[:rotations].length).to eq(0)
    end
  end

  describe 'birthdays' do
    it 'includes active residents with birthdays in the month' do
      resident # force creation (April birthday)
      result = serialize
      expect(result[:birthdays].length).to eq(1)
      expect(result[:birthdays].first[:type]).to eq("Birthday")
    end

    it 'excludes inactive residents' do
      resident.update!(active: false, can_cook: false, email: nil)
      result = serialize
      expect(result[:birthdays].length).to eq(0)
    end
  end

  describe 'events' do
    it 'includes events within the date range' do
      FactoryBot.create(:event, community: community,
        start_date: Time.zone.local(2026, 4, 10, 18, 0),
        end_date: Time.zone.local(2026, 4, 10, 20, 0))

      result = serialize
      expect(result[:events].length).to eq(1)
    end

    it 'includes events that span across the date range boundaries' do
      FactoryBot.create(:event, community: community,
        start_date: Time.zone.local(2026, 3, 28, 0, 0),
        end_date: Time.zone.local(2026, 4, 5, 0, 0))

      result = serialize
      expect(result[:events].length).to eq(1)
    end
  end

  describe 'common_house_reservations' do
    it 'includes reservations within the date range' do
      FactoryBot.create(:common_house_reservation, community: community, resident: resident,
        start_date: Time.zone.local(2026, 4, 12, 14, 0),
        end_date: Time.zone.local(2026, 4, 12, 17, 0))

      result = serialize
      expect(result[:common_house_reservations].length).to eq(1)
    end
  end

  describe 'guest_room_reservations' do
    it 'includes reservations within the date range' do
      FactoryBot.create(:guest_room_reservation, community: community, resident: resident,
        date: Date.new(2026, 4, 20))

      result = serialize
      expect(result[:guest_room_reservations].length).to eq(1)
    end
  end
end
