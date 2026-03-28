require 'rails_helper'

RSpec.describe "Rotations API", type: :request do
  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }
  let(:resident) { FactoryBot.create(:resident, community: community, unit: unit) }
  let(:token) { resident.key.token }

  before do
    allow(Pusher).to receive(:trigger)
  end

  describe "GET /api/v1/rotations" do
    it "returns rotations for the community" do
      rotation = FactoryBot.create(:rotation, community: community)
      FactoryBot.create(:meal, community: community, rotation: rotation)

      get "/api/v1/rotations", params: { community_id: community.id, token: token }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(1)
    end

    it "filters by date range via meal dates" do
      old_rotation = FactoryBot.create(:rotation, community: community)
      FactoryBot.create(:meal, community: community, rotation: old_rotation, date: Date.new(2025, 1, 15))

      new_rotation = FactoryBot.create(:rotation, community: community)
      FactoryBot.create(:meal, community: community, rotation: new_rotation, date: Date.new(2026, 4, 15))

      get "/api/v1/rotations", params: {
        community_id: community.id, token: token,
        start: "2026-04-01", end: "2026-05-01"
      }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.length).to eq(1)
    end

    it "returns 401 without a token" do
      get "/api/v1/rotations", params: { community_id: community.id }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 for a resident from another community" do
      other_community = FactoryBot.create(:community)
      other_unit = FactoryBot.create(:unit, community: other_community)
      other_resident = FactoryBot.create(:resident, community: other_community, unit: other_unit)

      get "/api/v1/rotations", params: {
        community_id: community.id, token: other_resident.key.token
      }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/rotations/:id" do
    it "returns the rotation with cook IDs" do
      rotation = FactoryBot.create(:rotation, community: community)
      meal = FactoryBot.create(:meal, community: community, rotation: rotation)
      cook = FactoryBot.create(:resident, community: community, unit: unit)
      FactoryBot.create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal("30"))

      get "/api/v1/rotations/#{rotation.id}", params: { token: token }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key("id")
      expect(body).to have_key("residents")
    end

    it "returns 404 for nonexistent rotation" do
      get "/api/v1/rotations/999999", params: { token: token }
      expect(response).to have_http_status(:not_found)
    end

    it "returns 403 for rotation in another community" do
      other_community = FactoryBot.create(:community)
      other_rotation = FactoryBot.create(:rotation, community: other_community)

      get "/api/v1/rotations/#{other_rotation.id}", params: { token: token }
      expect(response).to have_http_status(:forbidden)
    end
  end
end
