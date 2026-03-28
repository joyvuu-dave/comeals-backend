require 'rails_helper'

RSpec.describe "Residents API", type: :request do
  let(:community) { FactoryBot.create(:community, slug: "testcom") }
  let(:unit) { FactoryBot.create(:unit, community: community) }
  let!(:resident) { FactoryBot.create(:resident, community: community, unit: unit, email: "alice@example.com", password: "correctpassword") }
  let(:token) { resident.key.token }

  # ---------------------------------------------------------------------------
  # POST /api/v1/residents/token (login)
  # ---------------------------------------------------------------------------
  describe "POST /api/v1/residents/token" do
    it "returns token and community info on valid credentials" do
      post "/api/v1/residents/token", params: {
        email: "alice@example.com",
        password: "correctpassword"
      }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["token"]).to eq(resident.key.token)
      expect(body["community_id"]).to eq(community.id)
      expect(body["resident_id"]).to eq(resident.id)
      expect(body["slug"]).to eq("testcom")
    end

    it "is case-insensitive on email" do
      post "/api/v1/residents/token", params: {
        email: "ALICE@EXAMPLE.COM",
        password: "correctpassword"
      }

      expect(response).to have_http_status(:ok)
    end

    it "returns 400 with wrong password" do
      post "/api/v1/residents/token", params: {
        email: "alice@example.com",
        password: "wrongpassword"
      }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to include("Incorrect password")
    end

    it "returns 400 with unknown email" do
      post "/api/v1/residents/token", params: {
        email: "nobody@example.com",
        password: "anything"
      }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to include("No resident with email")
    end

    it "returns 400 with blank email" do
      post "/api/v1/residents/token", params: { email: "", password: "anything" }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to eq("Email required.")
    end
  end

  # ---------------------------------------------------------------------------
  # GET /api/v1/residents/id
  # ---------------------------------------------------------------------------
  describe "GET /api/v1/residents/id" do
    it "returns the authenticated resident's ID" do
      get "/api/v1/residents/id", params: { token: token }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(resident.id)
    end

    it "returns 401 without a token" do
      get "/api/v1/residents/id"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  # ---------------------------------------------------------------------------
  # GET /api/v1/residents/name/:token
  # ---------------------------------------------------------------------------
  describe "GET /api/v1/residents/name/:token" do
    it "returns the resident name for a valid reset token" do
      resident.update!(reset_password_token: "valid-token-123")

      get "/api/v1/residents/name/valid-token-123"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["name"]).to be_present
    end

    it "returns 400 for an invalid reset token" do
      get "/api/v1/residents/name/bogus-token"

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to include("incorrect or expired")
    end
  end

  # ---------------------------------------------------------------------------
  # POST /api/v1/residents/password-reset/:token (password_new)
  # ---------------------------------------------------------------------------
  describe "POST /api/v1/residents/password-reset/:token" do
    it "sets a new password with a valid reset token" do
      resident.update!(reset_password_token: "reset-token-456")

      post "/api/v1/residents/password-reset/reset-token-456", params: {
        password: "newpassword123"
      }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Password updated!")

      # Verify new password works
      expect(resident.reload.authenticate("newpassword123")).to be_truthy
    end

    it "returns 400 for an invalid reset token" do
      post "/api/v1/residents/password-reset/bogus-token", params: {
        password: "newpassword123"
      }

      expect(response).to have_http_status(:bad_request)
    end
  end
end
