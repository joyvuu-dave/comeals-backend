# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Serializers', type: :serializer do
  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }
  let(:resident) { create(:resident, community: community, unit: unit) }

  before do
    allow(Pusher).to receive(:trigger)
  end

  def serialize(object, serializer, options = {})
    ActiveModelSerializers::SerializableResource.new(object, { serializer: serializer }.merge(options)).as_json
  end

  describe MealSerializer do
    it 'includes all expected attributes' do
      meal = create(:meal, community: community, date: Date.yesterday)

      result = serialize(meal, described_class)
      expect(result).to have_key(:id)
      expect(result).to have_key(:title)
      expect(result).to have_key(:start)
      expect(result).to have_key(:end)
      expect(result).to have_key(:url)
      expect(result).to have_key(:color)
      expect(result[:color]).to eq('#444')
      expect(result[:url]).to eq("/meals/#{meal.id}/edit")
    end

    it 'shows attendee count and "attended" for past meals' do
      meal = create(:meal, community: community, date: Date.yesterday)
      create(:meal_resident, meal: meal, resident: resident, community: community)

      result = serialize(meal, described_class)
      expect(result[:title]).to include('1')
      expect(result[:title]).to include('attended')
    end

    it 'shows "signed up" for future meals' do
      meal = create(:meal, community: community, date: Date.tomorrow)

      result = serialize(meal, described_class)
      expect(result[:title]).to include('signed up')
    end

    it 'shows extras count for future closed meals with a max' do
      meal = create(:meal, community: community, date: Date.tomorrow)
      create(:meal_resident, meal: meal, resident: resident, community: community)
      meal.update!(closed: true, max: 10)

      result = serialize(meal, described_class)
      expect(result[:title]).to include('9 extras')
    end

    it 'shows "1 extra" (singular) when exactly 1 spot remains' do
      meal = create(:meal, community: community, date: Date.tomorrow)
      create(:meal_resident, meal: meal, resident: resident, community: community)
      meal.update!(closed: true, max: 2)

      result = serialize(meal, described_class)
      expect(result[:title]).to include('1 extra')
      expect(result[:title]).not_to include('1 extras')
    end
  end

  describe MealFormSerializer::BillSerializer do
    # BigDecimal amounts must serialize as JSON strings, not floats.
    # Floats lose precision (0.1 + 0.2 != 0.3). This test ensures
    # Oj.optimize_rails preserves the string convention. If this test
    # fails, financial data is being silently corrupted in transit.
    it 'serializes BigDecimal amounts as strings, not floats' do
      meal = create(:meal, community: community)
      bill = create(:bill, meal: meal, resident: resident, community: community,
                           amount: BigDecimal('50.12345678'))

      json = ActiveModelSerializers::SerializableResource.new(
        bill, serializer: described_class
      ).to_json
      parsed = JSON.parse(json)

      expect(parsed['amount']).to be_a(String)
      expect(BigDecimal(parsed['amount'])).to eq(BigDecimal('50.12345678'))
    end
  end

  describe BillSerializer do
    it 'includes cook name and unit' do
      meal = create(:meal, community: community, date: Date.yesterday)
      bill = create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal('50'))

      result = serialize(bill, described_class)
      expect(result[:title]).to include('Cook')
      expect(result[:url]).to eq("/meals/#{meal.id}/edit")
    end

    it 'includes amount for past meals with amount > 0' do
      meal = create(:meal, community: community, date: Date.yesterday)
      bill = create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal('50'))

      result = serialize(bill, described_class)
      expect(result[:title]).to include('$50.00')
    end

    it 'omits amount for future meals' do
      meal = create(:meal, community: community, date: Date.tomorrow)
      bill = create(:bill, meal: meal, resident: resident, community: community, amount: BigDecimal('50'))

      result = serialize(bill, described_class)
      expect(result[:title]).not_to include('$50.00')
    end
  end

  describe EventSerializer do
    it 'formats timed events with time range' do
      event = create(:event, community: community,
                             title: 'Movie Night', allday: false,
                             start_date: Time.zone.local(2026, 4, 1, 19, 0),
                             end_date: Time.zone.local(2026, 4, 1, 21, 0))

      result = serialize(event, described_class)
      expect(result[:title]).to include('Movie Night')
      expect(result[:allDay]).to be false
      expect(result[:color]).to eq('#7ebc35')
    end

    it 'formats all-day events' do
      event = create(:event, community: community,
                             title: 'Work Day', allday: true,
                             start_date: Time.zone.local(2026, 4, 1, 0, 0),
                             end_date: nil)

      result = serialize(event, described_class)
      expect(result[:title]).to include('ALL DAY')
      expect(result[:allDay]).to be true
    end
  end

  describe RotationSerializer do
    it 'spans from first to last meal date' do
      rotation = create(:rotation, community: community)
      create(:meal, community: community, rotation: rotation, date: Date.new(2026, 3, 1))
      create(:meal, community: community, rotation: rotation, date: Date.new(2026, 3, 15))

      result = serialize(rotation, described_class)
      expect(result[:start].to_date).to eq(Date.new(2026, 3, 1))
      expect(result[:title]).to include('Rotation')
      expect(result[:url]).to eq("rotations/show/#{rotation.id}")
    end

    it 'returns nil start/end for a rotation with no meals' do
      rotation = create(:rotation, community: community)

      result = serialize(rotation, described_class)
      expect(result[:start]).to be_nil
      expect(result[:end]).to be_nil
    end
  end

  describe CommonHouseReservationSerializer do
    it 'includes time range, resident name, and unit' do
      chr = create(:common_house_reservation, community: community, resident: resident,
                                              start_date: Time.zone.local(2026, 4, 1, 14, 0),
                                              end_date: Time.zone.local(2026, 4, 1, 17, 0))

      result = serialize(chr, described_class)
      expect(result[:title]).to include('Common House')
      expect(result[:color]).to eq('#bc357e')
      expect(result[:url]).to eq("common-house-reservations/edit/#{chr.id}")
    end
  end

  describe GuestRoomReservationSerializer do
    it 'includes resident name and unit' do
      grr = create(:guest_room_reservation, community: community, resident: resident,
                                            date: Date.new(2026, 4, 10))

      result = serialize(grr, described_class)
      expect(result[:title]).to include('Guest Room')
      expect(result[:color]).to eq('#bc7335')
      expect(result[:url]).to eq("guest-room-reservations/edit/#{grr.id}")
    end
  end

  describe ResidentBirthdaySerializer do
    it 'shows age milestone for residents under 22' do
      young = create(:resident, community: community, unit: unit,
                                birthday: Date.new(2015, 4, 15))

      result = serialize(young, described_class)
      expect(result[:type]).to eq('Birthday')
      expect(result[:title]).to include('B-day!')
      expect(result[:title]).to match(/\d+\w+ B-day!/)
      expect(result[:color]).to eq('#7335bc')
    end

    it 'omits age for residents 22 and older' do
      adult = create(:resident, community: community, unit: unit,
                                birthday: Date.new(1990, 4, 15))

      result = serialize(adult, described_class)
      expect(result[:title]).to include('B-day!')
      expect(result[:title]).not_to match(/\d+\w+ B-day!/)
    end
  end

  describe RotationLogSerializer do
    it 'includes residents with signed_up status' do
      rotation = create(:rotation, community: community)
      meal = create(:meal, community: community, rotation: rotation)
      cook = create(:resident, community: community, unit: unit)
      create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal('30'))

      result = serialize(rotation, described_class, cook_ids: rotation.cook_ids)
      expect(result[:id]).to eq(rotation.place_value)
      expect(result[:residents]).to be_an(Array)

      cook_entry = result[:residents].find { |r| r[:id] == cook.id }
      expect(cook_entry[:signed_up]).to be true
    end
  end
end
