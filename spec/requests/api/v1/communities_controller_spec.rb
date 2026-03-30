# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Communities API' do
  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }
  let(:resident) { create(:resident, community: community, unit: unit) }
  let(:token) { resident.key.token }

  before do
    allow(Pusher).to receive(:trigger)
  end

  describe 'GET /api/v1/communities/:id/hosts' do
    it 'returns active adult residents ordered by unit' do
      adult = create(:resident, community: community, unit: unit, multiplier: 2, active: true)
      child = create(:resident, community: community, unit: unit, multiplier: 1, active: true)
      inactive = create(:resident, community: community, unit: unit, multiplier: 2, active: false,
                                   can_cook: false, email: nil)

      get "/api/v1/communities/#{community.id}/hosts", params: { token: token }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      host_ids = body.pluck(0)
      expect(host_ids).to include(resident.id)
      expect(host_ids).to include(adult.id)
      expect(host_ids).not_to include(child.id)
      expect(host_ids).not_to include(inactive.id)
    end

    it 'returns 401 without a token' do
      get "/api/v1/communities/#{community.id}/hosts"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 403 for a resident from another community' do
      other_community = create(:community)
      other_unit = create(:unit, community: other_community)
      other_resident = create(:resident, community: other_community, unit: other_unit)

      get "/api/v1/communities/#{community.id}/hosts", params: { token: other_resident.key.token }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /api/v1/communities/:id/birthdays' do
    it 'returns residents with birthdays in the target month' do
      march_bday = create(:resident, community: community, unit: unit,
                                     birthday: Date.new(1990, 3, 15))
      create(:resident, community: community, unit: unit,
                        birthday: Date.new(1985, 7, 20))

      get "/api/v1/communities/#{community.id}/birthdays", params: {
        token: token, start: '2026-03-01'
      }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      names = body.pluck('title')
      expect(names.join).to include(march_bday.name.split[0])
    end

    it "returns 403 when community ID does not match resident's community" do
      get '/api/v1/communities/999999/birthdays', params: { token: token }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /api/v1/communities/:id/calendar/:date' do
    it 'returns calendar data for the month' do
      create(:meal, community: community, date: Date.new(2026, 4, 10))

      get "/api/v1/communities/#{community.id}/calendar/2026-04-15", params: { token: token }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to have_key('month')
      expect(body).to have_key('year')
      expect(body['month']).to eq(4)
      expect(body['year']).to eq(2026)
    end
  end

  describe 'GET /api/v1/communities/:id/ical' do
    it 'returns an iCalendar feed (no auth required)' do
      create(:meal, community: community, date: Date.new(2026, 5, 1))

      get "/api/v1/communities/#{community.id}/ical"

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('text/calendar')
      expect(response.body).to include('BEGIN:VCALENDAR')
      expect(response.body).to include('Common Dinner')
    end
  end
end
