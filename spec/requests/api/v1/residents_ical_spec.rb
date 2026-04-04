# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Residents iCal API' do
  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }
  let(:resident) { create(:resident, community: community, unit: unit) }

  # Sunday meal (18:00 start) and weekday meal (19:00 start)
  let(:sunday_meal) { create(:meal, community: community, date: Date.new(2026, 4, 5)) }   # Sunday
  let(:weekday_meal) { create(:meal, community: community, date: Date.new(2026, 4, 7)) }  # Tuesday

  describe 'GET /api/v1/residents/:id/ical' do
    it 'returns a valid iCalendar document' do
      create(:bill, meal: sunday_meal, resident: resident, community: community)

      get "/api/v1/residents/#{resident.id}/ical"

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('text/calendar')
      expect(response.body).to include('BEGIN:VCALENDAR')
      expect(response.body).to include('END:VCALENDAR')
    end

    it 'includes Cook events for meals where the resident has a bill' do
      create(:bill, meal: sunday_meal, resident: resident, community: community)

      get "/api/v1/residents/#{resident.id}/ical"

      expect(response.body).to include('Cook Common Dinner')
    end

    it 'includes Attend events for meals where the resident signed up' do
      create(:meal_resident, meal: weekday_meal, resident: resident, community: community)

      get "/api/v1/residents/#{resident.id}/ical"

      expect(response.body).to include('Attend Common Dinner')
    end

    it 'does not duplicate a meal as both Cook and Attend' do
      # Resident is both cooking and attending the same meal
      create(:bill, meal: sunday_meal, resident: resident, community: community)
      create(:meal_resident, meal: sunday_meal, resident: resident, community: community)

      get "/api/v1/residents/#{resident.id}/ical"

      # Should have exactly one Cook event and zero Attend events for this date
      events = response.body.scan(/SUMMARY:(.+)/).map { |e| e[0].strip }
      cook_events = events.count { |e| e == 'Cook Common Dinner' }
      attend_events = events.count { |e| e == 'Attend Common Dinner' }

      expect(cook_events).to eq(1)
      expect(attend_events).to eq(0)
    end

    it 'uses 18:00 start for Sunday meals and 19:00 for weekday meals' do
      create(:bill, meal: sunday_meal, resident: resident, community: community)
      create(:meal_resident, meal: weekday_meal, resident: resident, community: community)

      get "/api/v1/residents/#{resident.id}/ical"

      # Sunday: 18:00 (T180000), weekday: 19:00 (T190000)
      expect(response.body).to include('T180000')
      expect(response.body).to include('T190000')
    end

    it 'returns an empty calendar for a resident with no meals' do
      get "/api/v1/residents/#{resident.id}/ical"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('BEGIN:VCALENDAR')
      expect(response.body).not_to include('BEGIN:VEVENT')
    end

    it 'does not require authentication' do
      get "/api/v1/residents/#{resident.id}/ical"
      expect(response).to have_http_status(:ok)
    end
  end
end
