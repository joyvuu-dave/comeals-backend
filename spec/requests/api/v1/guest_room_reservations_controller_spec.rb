require 'rails_helper'

RSpec.describe "Guest Room Reservations API", type: :request do
  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }
  let(:resident) { FactoryBot.create(:resident, community: community, unit: unit) }
  let(:token) { resident.key.token }

  before do
    allow(Pusher).to receive(:trigger)
  end

  describe "GET /api/v1/guest-room-reservations" do
    it "returns reservations for the community" do
      FactoryBot.create(:guest_room_reservation, community: community, resident: resident)

      get "/api/v1/guest-room-reservations", params: { community_id: community.id, token: token }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(1)
    end

    it "filters by date range" do
      old = FactoryBot.create(:guest_room_reservation, community: community, resident: resident, date: 1.year.ago.to_date)
      recent = FactoryBot.create(:guest_room_reservation, community: community, resident: resident, date: Date.yesterday)

      get "/api/v1/guest-room-reservations", params: {
        community_id: community.id, token: token,
        start: 1.week.ago.to_date.to_s, end: Date.today.to_s
      }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(1)
    end

    it "returns 401 without a token" do
      get "/api/v1/guest-room-reservations", params: { community_id: community.id }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 for a resident from another community" do
      other_community = FactoryBot.create(:community)
      other_unit = FactoryBot.create(:unit, community: other_community)
      other_resident = FactoryBot.create(:resident, community: other_community, unit: other_unit)

      get "/api/v1/guest-room-reservations", params: {
        community_id: community.id, token: other_resident.key.token
      }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/guest-room-reservations/:id" do
    it "returns the reservation with host list" do
      grr = FactoryBot.create(:guest_room_reservation, community: community, resident: resident)

      get "/api/v1/guest-room-reservations/#{grr.id}", params: { token: token }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key("event")
      expect(body).to have_key("hosts")
    end

    it "returns 404 for nonexistent reservation" do
      get "/api/v1/guest-room-reservations/999999", params: { token: token }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/guest-room-reservations" do
    it "creates a reservation" do
      post "/api/v1/guest-room-reservations", params: {
        community_id: community.id, token: token,
        resident_id: resident.id, date: Date.tomorrow.to_s
      }

      expect(response).to have_http_status(:ok)
      expect(GuestRoomReservation.count).to eq(1)
    end

    it "rejects duplicate date for same community" do
      FactoryBot.create(:guest_room_reservation, community: community, resident: resident, date: Date.tomorrow)

      post "/api/v1/guest-room-reservations", params: {
        community_id: community.id, token: token,
        resident_id: resident.id, date: Date.tomorrow.to_s
      }

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "PATCH /api/v1/guest-room-reservations/:id/update" do
    it "updates the reservation" do
      grr = FactoryBot.create(:guest_room_reservation, community: community, resident: resident)

      patch "/api/v1/guest-room-reservations/#{grr.id}/update", params: {
        token: token, date: (Date.today + 10).to_s, resident_id: resident.id
      }

      expect(response).to have_http_status(:ok)
      expect(grr.reload.date).to eq(Date.today + 10)
    end
  end

  describe "DELETE /api/v1/guest-room-reservations/:id/delete" do
    it "deletes the reservation" do
      grr = FactoryBot.create(:guest_room_reservation, community: community, resident: resident)

      expect {
        delete "/api/v1/guest-room-reservations/#{grr.id}/delete", params: { token: token }
      }.to change(GuestRoomReservation, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end
  end
end
