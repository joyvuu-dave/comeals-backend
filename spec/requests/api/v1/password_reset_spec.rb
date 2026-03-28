require 'rails_helper'

RSpec.describe "POST /api/v1/residents/password-reset", type: :request do
  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }
  let!(:resident) { FactoryBot.create(:resident, community: community, unit: unit, email: "sarah@example.com") }

  def request_reset(email:)
    post "/api/v1/residents/password-reset", params: { email: email }
  end

  describe "successful password reset" do
    it "returns 200 with a success message" do
      request_reset(email: "sarah@example.com")

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Check your email.")
    end

    it "sets a reset_password_token on the resident" do
      expect { request_reset(email: "sarah@example.com") }
        .to change { resident.reload.reset_password_token }.from(nil)
    end

    it "sends a password reset email" do
      expect { request_reset(email: "sarah@example.com") }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "email delivery failure" do
    before do
      mail_double = instance_double(ActionMailer::MessageDelivery)
      allow(ResidentMailer).to receive(:password_reset_email).and_return(mail_double)
      allow(mail_double).to receive(:deliver_now).and_raise(Net::ReadTimeout)
    end

    it "returns 503 with a helpful message" do
      request_reset(email: "sarah@example.com")

      expect(response).to have_http_status(:service_unavailable)
      expect(JSON.parse(response.body)["message"]).to include("email could not be sent")
    end

    it "still saves the reset token so the user can retry" do
      request_reset(email: "sarah@example.com")

      expect(resident.reload.reset_password_token).to be_present
    end

    it "logs the error" do
      allow(Rails.logger).to receive(:error)

      request_reset(email: "sarah@example.com")

      expect(Rails.logger).to have_received(:error).with(/Password reset email failed.*Net::ReadTimeout/)
    end
  end

  describe "validation errors" do
    it "returns 400 when email is missing" do
      post "/api/v1/residents/password-reset", params: {}

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to eq("Email required.")
    end

    it "returns 400 when no resident matches the email" do
      request_reset(email: "nobody@example.com")

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to eq("No resident with that email address.")
    end
  end
end
