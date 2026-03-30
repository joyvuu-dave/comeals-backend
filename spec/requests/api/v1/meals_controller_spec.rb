# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Meals API' do
  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }
  let(:resident) { create(:resident, community: community, unit: unit) }
  let(:token) { resident.key.token }

  before do
    allow(Pusher).to receive(:trigger)
  end

  # ---------------------------------------------------------------------------
  # GET /api/v1/meals
  # ---------------------------------------------------------------------------
  describe 'GET /api/v1/meals' do
    it 'returns meals for the community' do
      create(:meal, community: community)

      get '/api/v1/meals', params: { community_id: community.id, token: token }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body.length).to eq(1)
    end

    it 'filters by date range when start and end are provided' do
      create(:meal, community: community, date: Date.new(2025, 1, 1))
      create(:meal, community: community, date: Date.new(2025, 6, 1))

      get '/api/v1/meals', params: {
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
      get '/api/v1/meals', params: { community_id: community.id }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 403 for a resident from another community' do
      other_community = create(:community)
      other_unit = create(:unit, community: other_community)
      other_resident = create(:resident, community: other_community, unit: other_unit)

      get '/api/v1/meals', params: {
        community_id: community.id,
        token: other_resident.key.token
      }

      expect(response).to have_http_status(:forbidden)
    end
  end

  # ---------------------------------------------------------------------------
  # GET /api/v1/meals/next
  # ---------------------------------------------------------------------------
  describe 'GET /api/v1/meals/next' do
    it 'returns the next upcoming meal' do
      future_meal = create(:meal, community: community, date: Time.zone.today + 1)

      get '/api/v1/meals/next', params: { token: token }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['meal_id']).to eq(future_meal.id)
    end

    it 'returns 400 when no future meals exist' do
      create(:meal, community: community, date: Date.yesterday)

      get '/api/v1/meals/next', params: { token: token }

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body['meal_id']).to be_nil
    end
  end

  # ---------------------------------------------------------------------------
  # GET /api/v1/meals/:meal_id
  # ---------------------------------------------------------------------------
  describe 'GET /api/v1/meals/:meal_id' do
    it 'returns the meal' do
      meal = create(:meal, community: community)

      get "/api/v1/meals/#{meal.id}", params: { token: token }

      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 for nonexistent meal' do
      get '/api/v1/meals/999999', params: { token: token }

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 403 for a meal in another community' do
      other_community = create(:community)
      other_meal = create(:meal, community: other_community)

      get "/api/v1/meals/#{other_meal.id}", params: { token: token }

      expect(response).to have_http_status(:forbidden)
    end
  end

  # ---------------------------------------------------------------------------
  # GET /api/v1/meals/:meal_id/history
  # ---------------------------------------------------------------------------
  describe 'GET /api/v1/meals/:meal_id/history' do
    it 'returns audit history for the meal' do
      meal = create(:meal, community: community)

      get "/api/v1/meals/#{meal.id}/history", params: { token: token }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to have_key('date')
      expect(body).to have_key('items')
    end
  end

  # ---------------------------------------------------------------------------
  # POST /api/v1/meals/:meal_id/residents/:resident_id (create_meal_resident)
  # ---------------------------------------------------------------------------
  describe 'POST /api/v1/meals/:meal_id/residents/:resident_id' do
    let(:meal) { create(:meal, community: community) }

    it 'signs up a resident for a meal' do
      post "/api/v1/meals/#{meal.id}/residents/#{resident.id}", params: {
        token: token, late: false, vegetarian: false
      }

      expect(response).to have_http_status(:ok)
      expect(meal.meal_residents.find_by(resident: resident)).to be_present
    end

    it 'copies the resident multiplier to the meal_resident' do
      resident.update!(multiplier: 1)

      post "/api/v1/meals/#{meal.id}/residents/#{resident.id}", params: {
        token: token, late: false, vegetarian: false
      }

      mr = meal.meal_residents.find_by(resident: resident)
      expect(mr.multiplier).to eq(1)
    end

    it 'sets late and vegetarian flags' do
      post "/api/v1/meals/#{meal.id}/residents/#{resident.id}", params: {
        token: token,
        late: true,
        vegetarian: true
      }

      mr = meal.meal_residents.find_by(resident: resident)
      expect(mr.late).to be(true)
      expect(mr.vegetarian).to be(true)
    end

    it 'is idempotent — re-signing up updates instead of erroring' do
      post "/api/v1/meals/#{meal.id}/residents/#{resident.id}", params: {
        token: token, late: false, vegetarian: false
      }
      expect(response).to have_http_status(:ok)

      post "/api/v1/meals/#{meal.id}/residents/#{resident.id}", params: {
        token: token, late: true, vegetarian: false
      }
      expect(response).to have_http_status(:ok)

      expect(meal.meal_residents.where(resident: resident).count).to eq(1)
      expect(meal.meal_residents.find_by(resident: resident).late).to be(true)
    end

    it 'rejects signup when meal is closed without max' do
      meal.update!(closed: true)

      post "/api/v1/meals/#{meal.id}/residents/#{resident.id}", params: {
        token: token, late: false, vegetarian: false
      }

      expect(response).to have_http_status(:bad_request)
      expect(meal.meal_residents.find_by(resident: resident)).to be_nil
    end

    it 'rejects signup when meal is at max capacity' do
      other = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: other, community: community)
      meal.update!(closed: true, max: 1)

      post "/api/v1/meals/#{meal.id}/residents/#{resident.id}", params: {
        token: token, late: false, vegetarian: false
      }

      expect(response).to have_http_status(:bad_request)
    end

    it 'allows signup when meal is closed but has open extras spots' do
      meal.update!(closed: true, max: 5)

      post "/api/v1/meals/#{meal.id}/residents/#{resident.id}", params: {
        token: token, late: false, vegetarian: false
      }

      expect(response).to have_http_status(:ok)
      expect(meal.meal_residents.find_by(resident: resident)).to be_present
    end
  end

  # ---------------------------------------------------------------------------
  # DELETE /api/v1/meals/:meal_id/residents/:resident_id (destroy_meal_resident)
  # ---------------------------------------------------------------------------
  describe 'DELETE /api/v1/meals/:meal_id/residents/:resident_id' do
    let(:meal) { create(:meal, community: community) }

    it 'removes a resident from a meal' do
      mr = create(:meal_resident, meal: meal, resident: resident, community: community)

      delete "/api/v1/meals/#{meal.id}/residents/#{resident.id}", params: { token: token }

      expect(response).to have_http_status(:ok)
      expect(MealResident.find_by(id: mr.id)).to be_nil
    end

    it 'blocks removal from a closed meal when resident signed up before closing' do
      create(:meal_resident, meal: meal, resident: resident, community: community)
      meal.update!(closed: true)

      expect do
        delete "/api/v1/meals/#{meal.id}/residents/#{resident.id}", params: { token: token }
      end.to raise_error(ActiveRecord::RecordNotDestroyed)
    end

    it 'returns 404 when meal_resident does not exist' do
      delete "/api/v1/meals/#{meal.id}/residents/#{resident.id}", params: { token: token }

      expect(response).to have_http_status(:not_found)
    end
  end

  # ---------------------------------------------------------------------------
  # PATCH /api/v1/meals/:meal_id/residents/:resident_id (update_meal_resident)
  # ---------------------------------------------------------------------------
  describe 'PATCH /api/v1/meals/:meal_id/residents/:resident_id' do
    let(:meal) { create(:meal, community: community) }
    let!(:meal_resident) { create(:meal_resident, meal: meal, resident: resident, community: community) }

    it 'updates late and vegetarian flags' do
      patch "/api/v1/meals/#{meal.id}/residents/#{resident.id}", params: {
        token: token,
        late: true,
        vegetarian: true
      }

      expect(response).to have_http_status(:ok)
      meal_resident.reload
      expect(meal_resident.late).to be(true)
      expect(meal_resident.vegetarian).to be(true)
    end
  end

  # ---------------------------------------------------------------------------
  # POST /api/v1/meals/:meal_id/residents/:resident_id/guests (create_guest)
  # ---------------------------------------------------------------------------
  describe 'POST /api/v1/meals/:meal_id/residents/:resident_id/guests' do
    let(:meal) { create(:meal, community: community) }

    it 'adds a guest to the meal' do
      post "/api/v1/meals/#{meal.id}/residents/#{resident.id}/guests", params: {
        token: token,
        vegetarian: false
      }

      expect(response).to have_http_status(:ok)
      expect(meal.guests.count).to eq(1)
      expect(meal.guests.first.resident).to eq(resident)
    end

    it 'sets the vegetarian flag on the guest' do
      post "/api/v1/meals/#{meal.id}/residents/#{resident.id}/guests", params: {
        token: token,
        vegetarian: true
      }

      expect(meal.guests.first.vegetarian).to be(true)
    end

    it 'rejects guest when meal is at max capacity' do
      other = create(:resident, community: community, unit: unit, multiplier: 2)
      create(:meal_resident, meal: meal, resident: other, community: community)
      meal.update!(closed: true, max: 1)

      post "/api/v1/meals/#{meal.id}/residents/#{resident.id}/guests", params: {
        token: token,
        vegetarian: false
      }

      expect(response).to have_http_status(:bad_request)
      expect(meal.guests.count).to eq(0)
    end
  end

  # ---------------------------------------------------------------------------
  # DELETE /api/v1/meals/:meal_id/residents/:resident_id/guests/:guest_id
  # ---------------------------------------------------------------------------
  describe 'DELETE /api/v1/meals/:meal_id/residents/:resident_id/guests/:guest_id' do
    let(:meal) { create(:meal, community: community) }

    it 'removes a guest from the meal' do
      guest = create(:guest, meal: meal, resident: resident)

      delete "/api/v1/meals/#{meal.id}/residents/#{resident.id}/guests/#{guest.id}", params: {
        token: token
      }

      expect(response).to have_http_status(:ok)
      expect(Guest.find_by(id: guest.id)).to be_nil
    end

    it 'returns 404 for nonexistent guest' do
      delete "/api/v1/meals/#{meal.id}/residents/#{resident.id}/guests/999999", params: {
        token: token
      }

      expect(response).to have_http_status(:not_found)
    end
  end

  # ---------------------------------------------------------------------------
  # GET /api/v1/meals/:meal_id/cooks
  # ---------------------------------------------------------------------------
  describe 'GET /api/v1/meals/:meal_id/cooks' do
    it 'returns meal form data with residents and bills' do
      meal = create(:meal, community: community)

      get "/api/v1/meals/#{meal.id}/cooks", params: { token: token }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to have_key('id')
      expect(body).to have_key('residents')
      expect(body).to have_key('bills')
    end
  end

  # ---------------------------------------------------------------------------
  # PATCH /api/v1/meals/:meal_id/description
  # ---------------------------------------------------------------------------
  describe 'PATCH /api/v1/meals/:meal_id/description' do
    let(:meal) { create(:meal, community: community) }

    it 'updates the meal description' do
      patch "/api/v1/meals/#{meal.id}/description", params: {
        token: token,
        description: 'Pasta night'
      }

      expect(response).to have_http_status(:ok)
      expect(meal.reload.description).to eq('Pasta night')
    end
  end

  # ---------------------------------------------------------------------------
  # PATCH /api/v1/meals/:meal_id/max
  # ---------------------------------------------------------------------------
  describe 'PATCH /api/v1/meals/:meal_id/max' do
    let(:meal) { create(:meal, community: community) }

    it 'updates the meal max capacity on a closed meal' do
      meal.update!(closed: true)

      patch "/api/v1/meals/#{meal.id}/max", params: {
        token: token,
        max: 10
      }

      expect(response).to have_http_status(:ok)
      expect(meal.reload.max).to eq(10)
    end

    it 'rejects max below current attendees count' do
      create(:meal_resident, meal: meal, resident: resident, community: community)
      meal.update!(closed: true)

      patch "/api/v1/meals/#{meal.id}/max", params: {
        token: token,
        max: 0
      }

      expect(response).to have_http_status(:bad_request)
    end
  end

  # ---------------------------------------------------------------------------
  # PATCH /api/v1/meals/:meal_id/closed
  # ---------------------------------------------------------------------------
  describe 'PATCH /api/v1/meals/:meal_id/closed' do
    let(:meal) { create(:meal, community: community) }

    it 'closes a meal' do
      patch "/api/v1/meals/#{meal.id}/closed", params: {
        token: token,
        closed: true
      }

      expect(response).to have_http_status(:ok)
      meal.reload
      expect(meal.closed).to be(true)
      expect(meal.closed_at).to be_present
    end

    it 'reopens a meal and clears max' do
      meal.update!(closed: true, max: 5)

      patch "/api/v1/meals/#{meal.id}/closed", params: {
        token: token,
        closed: false
      }

      expect(response).to have_http_status(:ok)
      meal.reload
      expect(meal.closed).to be(false)
      expect(meal.closed_at).to be_nil
      expect(meal.max).to be_nil
    end
  end
end
