require 'rails_helper'

RSpec.describe "Bills API", type: :request do
  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }
  let(:resident) { FactoryBot.create(:resident, community: community, unit: unit) }
  let(:token) { resident.key.token }

  before do
    allow(Pusher).to receive(:trigger)
  end

  # ---------------------------------------------------------------------------
  # GET /api/v1/bills
  # ---------------------------------------------------------------------------
  describe "GET /api/v1/bills" do
    let(:cook) { FactoryBot.create(:resident, community: community, unit: unit) }
    let(:meal1) { FactoryBot.create(:meal, community: community, date: Date.new(2025, 3, 1)) }
    let(:meal2) { FactoryBot.create(:meal, community: community, date: Date.new(2025, 6, 1)) }
    let!(:bill1) { FactoryBot.create(:bill, meal: meal1, resident: cook, community: community, amount: BigDecimal("30")) }
    let!(:bill2) { FactoryBot.create(:bill, meal: meal2, resident: cook, community: community, amount: BigDecimal("50")) }

    it "returns all bills for the community" do
      get "/api/v1/bills", params: { community_id: community.id, token: token }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.length).to eq(2)
    end

    it "filters bills by date range" do
      get "/api/v1/bills", params: {
        community_id: community.id,
        token: token,
        start: "2025-05-01",
        end: "2025-07-01"
      }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.length).to eq(1)
    end

    it "returns 401 without a token" do
      get "/api/v1/bills", params: { community_id: community.id }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 for a resident from another community" do
      other_community = FactoryBot.create(:community)
      other_unit = FactoryBot.create(:unit, community: other_community)
      other_resident = FactoryBot.create(:resident, community: other_community, unit: other_unit)

      get "/api/v1/bills", params: {
        community_id: community.id,
        token: other_resident.key.token
      }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/bills/:id" do
    it "returns the bill" do
      cook = FactoryBot.create(:resident, community: community, unit: unit)
      meal = FactoryBot.create(:meal, community: community)
      bill = FactoryBot.create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal("30"))

      get "/api/v1/bills/#{bill.id}", params: {
        community_id: community.id, token: token
      }

      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for nonexistent bill" do
      get "/api/v1/bills/999999", params: {
        community_id: community.id, token: token
      }

      expect(response).to have_http_status(:not_found)
    end
  end
end
