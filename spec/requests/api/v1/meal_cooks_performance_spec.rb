# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Meal show_cooks endpoint performance' do
  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }
  let(:resident) { create(:resident, community: community, unit: unit) }
  let(:token) { resident.key.token }
  let(:meal) { create(:meal, community: community) }

  before do
    allow(Pusher).to receive(:trigger)

    # Create a bill and some attendees to exercise the serializer
    create(:bill, meal: meal, resident: resident, community: community)
    5.times do
      r = create(:resident, community: community, unit: unit)
      create(:meal_resident, meal: meal, resident: r, community: community)
    end
  end

  it 'loads meal form in a bounded number of queries on cache miss' do
    Rails.cache.clear

    query_count = count_queries do
      get "/api/v1/meals/#{meal.id}/cooks", params: { token: token }
    end

    expect(response).to have_http_status(:ok)
    expect(query_count).to be <= 10
  end

  it 'serves cached meal form with minimal queries' do
    original_store = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new

    # Prime
    get "/api/v1/meals/#{meal.id}/cooks", params: { token: token }

    query_count = count_queries do
      get "/api/v1/meals/#{meal.id}/cooks", params: { token: token }
    end

    expect(response).to have_http_status(:ok)
    expect(query_count).to be <= 6
  ensure
    Rails.cache = original_store
  end
end
