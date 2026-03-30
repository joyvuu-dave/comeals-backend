# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bills API' do
  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }
  let(:resident) { create(:resident, community: community, unit: unit) }
  let(:token) { resident.key.token }

  before do
    allow(Pusher).to receive(:trigger)
  end

  # ---------------------------------------------------------------------------
  # GET /api/v1/bills
  # ---------------------------------------------------------------------------
  describe 'GET /api/v1/bills' do
    let(:cook) { create(:resident, community: community, unit: unit) }
    let(:meal1) { create(:meal, community: community, date: Date.new(2025, 3, 1)) }
    let(:meal2) { create(:meal, community: community, date: Date.new(2025, 6, 1)) }
    let!(:bill1) do # rubocop:disable RSpec/LetSetup -- creates data needed by index endpoint
      create(:bill, meal: meal1, resident: cook, community: community, amount: BigDecimal('30'))
    end
    let!(:bill2) do # rubocop:disable RSpec/LetSetup -- creates data needed by index endpoint
      create(:bill, meal: meal2, resident: cook, community: community, amount: BigDecimal('50'))
    end

    it 'returns all bills for the community' do
      get '/api/v1/bills', params: { community_id: community.id, token: token }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body.length).to eq(2)
    end

    it 'filters bills by date range' do
      get '/api/v1/bills', params: {
        community_id: community.id,
        token: token,
        start: '2025-05-01',
        end: '2025-07-01'
      }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body.length).to eq(1)
    end

    it 'returns 401 without a token' do
      get '/api/v1/bills', params: { community_id: community.id }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 403 for a resident from another community' do
      other_community = create(:community)
      other_unit = create(:unit, community: other_community)
      other_resident = create(:resident, community: other_community, unit: other_unit)

      get '/api/v1/bills', params: {
        community_id: community.id,
        token: other_resident.key.token
      }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /api/v1/bills/:id' do
    it 'returns the bill' do
      cook = create(:resident, community: community, unit: unit)
      meal = create(:meal, community: community)
      bill = create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal('30'))

      get "/api/v1/bills/#{bill.id}", params: {
        community_id: community.id, token: token
      }

      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 for nonexistent bill' do
      get '/api/v1/bills/999999', params: {
        community_id: community.id, token: token
      }

      expect(response).to have_http_status(:not_found)
    end
  end
end
