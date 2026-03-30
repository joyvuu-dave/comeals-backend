# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Common House Reservations API' do
  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }
  let(:resident) { create(:resident, community: community, unit: unit) }
  let(:token) { resident.key.token }

  before do
    allow(Pusher).to receive(:trigger)
  end

  describe 'GET /api/v1/common-house-reservations' do
    it 'returns reservations for the community' do
      create(:common_house_reservation, community: community, resident: resident)

      get '/api/v1/common-house-reservations', params: { community_id: community.id, token: token }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.length).to eq(1)
    end

    it 'filters by date range' do
      create(:common_house_reservation, community: community, resident: resident,
                                        start_date: Time.zone.local(2025, 1, 15, 14, 0),
                                        end_date: Time.zone.local(2025, 1, 15, 17, 0))
      create(:common_house_reservation, community: community, resident: resident,
                                        start_date: Time.zone.local(2026, 4, 10, 14, 0),
                                        end_date: Time.zone.local(2026, 4, 10, 17, 0))

      get '/api/v1/common-house-reservations', params: {
        community_id: community.id, token: token,
        start: '2026-04-01', end: '2026-04-30'
      }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.length).to eq(1)
    end

    it 'returns 401 without a token' do
      get '/api/v1/common-house-reservations', params: { community_id: community.id }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 403 for a resident from another community' do
      other_community = create(:community)
      other_unit = create(:unit, community: other_community)
      other_resident = create(:resident, community: other_community, unit: other_unit)

      get '/api/v1/common-house-reservations', params: {
        community_id: community.id, token: other_resident.key.token
      }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /api/v1/common-house-reservations/:id' do
    it 'returns the reservation with resident list' do
      chr = create(:common_house_reservation, community: community, resident: resident)

      get "/api/v1/common-house-reservations/#{chr.id}", params: { token: token }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to have_key('event')
      expect(body).to have_key('residents')
    end

    it 'returns 404 for nonexistent reservation' do
      get '/api/v1/common-house-reservations/999999', params: { token: token }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/common-house-reservations' do
    it 'creates a reservation' do
      post '/api/v1/common-house-reservations', params: {
        community_id: community.id, token: token,
        resident_id: resident.id, title: 'Birthday party',
        start_year: 2026, start_month: 5, start_day: 1,
        start_hours: 14, start_minutes: 0,
        end_hours: 17, end_minutes: 0
      }

      expect(response).to have_http_status(:ok)
      expect(CommonHouseReservation.count).to eq(1)
      expect(CommonHouseReservation.last.title).to eq('Birthday party')
    end

    it 'rejects overlapping reservations in the same community' do
      create(:common_house_reservation, community: community, resident: resident,
                                        start_date: Time.zone.local(2026, 5, 1, 14, 0),
                                        end_date: Time.zone.local(2026, 5, 1, 17, 0))

      post '/api/v1/common-house-reservations', params: {
        community_id: community.id, token: token,
        resident_id: resident.id, title: 'Conflict',
        start_year: 2026, start_month: 5, start_day: 1,
        start_hours: 15, start_minutes: 0,
        end_hours: 18, end_minutes: 0
      }

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'PATCH /api/v1/common-house-reservations/:id/update' do
    it 'updates the reservation' do
      chr = create(:common_house_reservation, community: community, resident: resident)

      patch "/api/v1/common-house-reservations/#{chr.id}/update", params: {
        token: token, resident_id: resident.id, title: 'Updated',
        start_year: 2026, start_month: 6, start_day: 1,
        start_hours: 10, start_minutes: 0,
        end_hours: 12, end_minutes: 0
      }

      expect(response).to have_http_status(:ok)
      expect(chr.reload.title).to eq('Updated')
    end
  end

  describe 'DELETE /api/v1/common-house-reservations/:id/delete' do
    it 'deletes the reservation' do
      chr = create(:common_house_reservation, community: community, resident: resident)

      expect do
        delete "/api/v1/common-house-reservations/#{chr.id}/delete", params: { token: token }
      end.to change(CommonHouseReservation, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end
  end
end
