# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Events API' do
  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }
  let(:resident) { create(:resident, community: community, unit: unit) }
  let(:token) { resident.key.token }

  before do
    allow(Pusher).to receive(:trigger)
  end

  describe 'GET /api/v1/events' do
    it 'returns events for the community' do
      create(:event, community: community)

      get '/api/v1/events', params: { community_id: community.id, token: token }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.length).to eq(1)
    end

    it 'filters by date range' do
      create(:event, community: community,
                     start_date: Time.zone.local(2025, 1, 15, 18, 0), end_date: Time.zone.local(2025, 1, 15, 20, 0))
      create(:event, community: community,
                     start_date: Time.zone.local(2026, 4, 10, 18, 0), end_date: Time.zone.local(2026, 4, 10, 20, 0))

      get '/api/v1/events', params: {
        community_id: community.id, token: token,
        start: '2026-04-01', end: '2026-04-30'
      }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.length).to eq(1)
    end

    it 'returns 401 without a token' do
      get '/api/v1/events', params: { community_id: community.id }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 403 for a resident from another community' do
      other_community = create(:community)
      other_unit = create(:unit, community: other_community)
      other_resident = create(:resident, community: other_community, unit: other_unit)

      get '/api/v1/events', params: { community_id: community.id, token: other_resident.key.token }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /api/v1/events/:id' do
    it 'returns the event' do
      event = create(:event, community: community)

      get "/api/v1/events/#{event.id}", params: { token: token }

      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 for nonexistent event' do
      get '/api/v1/events/999999', params: { token: token }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 403 for event in another community' do
      other_event = create(:event, community: create(:community))

      get "/api/v1/events/#{other_event.id}", params: { token: token }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'POST /api/v1/events' do
    it 'creates a timed event' do
      post '/api/v1/events', params: {
        community_id: community.id, token: token,
        title: 'Movie Night', description: 'Bring popcorn',
        all_day: false,
        start_year: 2026, start_month: 4, start_day: 15,
        start_hours: 19, start_minutes: 0,
        end_hours: 21, end_minutes: 30
      }

      expect(response).to have_http_status(:ok)
      event = Event.last
      expect(event.title).to eq('Movie Night')
      expect(event.allday).to be(false)
      expect(event.end_date).to be_present
    end

    it 'creates an all-day event' do
      post '/api/v1/events', params: {
        community_id: community.id, token: token,
        title: 'Work Day', all_day: true,
        start_year: 2026, start_month: 4, start_day: 20
      }

      expect(response).to have_http_status(:ok)
      event = Event.last
      expect(event.allday).to be(true)
      expect(event.end_date).to be_nil
    end

    it 'returns 400 without a title' do
      post '/api/v1/events', params: {
        community_id: community.id, token: token,
        title: '', all_day: true,
        start_year: 2026, start_month: 5, start_day: 1
      }

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'PATCH /api/v1/events/:id/update' do
    let!(:event) { create(:event, community: community) }

    it 'updates the event' do
      patch "/api/v1/events/#{event.id}/update", params: {
        token: token, title: 'Updated Title', description: 'New desc',
        all_day: false,
        start_year: 2026, start_month: 5, start_day: 1,
        start_hours: 18, start_minutes: 0,
        end_hours: 20, end_minutes: 0
      }

      expect(response).to have_http_status(:ok)
      expect(event.reload.title).to eq('Updated Title')
    end
  end

  describe 'DELETE /api/v1/events/:id/delete' do
    let!(:event) { create(:event, community: community) }

    it 'deletes the event' do
      expect do
        delete "/api/v1/events/#{event.id}/delete", params: { token: token }
      end.to change(Event, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end
  end
end
