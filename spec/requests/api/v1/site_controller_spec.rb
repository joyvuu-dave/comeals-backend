# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Site API' do
  describe 'GET /api/v1/version' do
    it 'returns version 0 in development/test' do
      get '/api/v1/version'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['version']).to eq(0)
    end
  end
end
