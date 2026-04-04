# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Calendar endpoint performance' do
  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }
  let(:resident) { create(:resident, community: community, unit: unit) }
  let(:token) { resident.key.token }

  before do
    allow(Pusher).to receive(:trigger)

    # Build a realistic month: 12 meals with bills, attendees, and a rotation
    rotation = create(:rotation, community: community)
    12.times do |i|
      meal = create(:meal, community: community, date: Date.new(2026, 4, 1) + i.days, rotation: rotation)
      create(:bill, meal: meal, resident: resident, community: community)
      create(:meal_resident, meal: meal, resident: resident, community: community)
    end
  end

  it 'loads calendar in a bounded number of queries' do
    # Warm the cache then clear it to test the compute path
    Rails.cache.clear

    query_count = count_queries do
      get "/api/v1/communities/#{community.id}/calendar/2026-04-15",
          params: { token: token }
    end

    expect(response).to have_http_status(:ok)
    expect(query_count).to be <= 20
  end

  it 'serves cached calendar with minimal queries' do
    # Test env uses null_store by default; switch to memory for this test
    original_store = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new

    # Prime the cache
    get "/api/v1/communities/#{community.id}/calendar/2026-04-15",
        params: { token: token }

    # Second request should only need auth queries, not serialization
    query_count = count_queries do
      get "/api/v1/communities/#{community.id}/calendar/2026-04-15",
          params: { token: token }
    end

    expect(response).to have_http_status(:ok)
    expect(query_count).to be <= 5
  ensure
    Rails.cache = original_store
  end
end
