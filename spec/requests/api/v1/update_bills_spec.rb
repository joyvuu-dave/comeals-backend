# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PATCH /api/v1/meals/:meal_id/bills' do
  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }
  let(:resident) { create(:resident, community: community, unit: unit) }
  let(:token) { resident.key.token }
  let(:meal) { create(:meal, community: community, date: Date.yesterday) }
  let(:cook) { create(:resident, community: community, unit: unit) }
  let!(:bill) { create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal('0')) }

  before do
    allow(Pusher).to receive(:trigger)
  end

  def update_bills(meal_id:, bills:, token: self.token)
    patch "/api/v1/meals/#{meal_id}/bills", params: {
      meal_id: meal_id,
      bills: bills,
      token: token
    }
  end

  describe 'successful bill update' do
    it 'updates bill amounts and returns 200' do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: '75.50', no_cost: false }]
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['message']).to eq('Form submitted.')

      bill.reload
      expect(bill.amount).to eq(BigDecimal('75.50'))
      expect(bill.no_cost).to be(false)
    end

    it 'stores amount as BigDecimal with full precision' do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: '50.01', no_cost: false }]
      )

      bill.reload
      expect(bill.amount).to be_a(BigDecimal)
      expect(bill.amount).to eq(BigDecimal('50.01'))
    end

    it 'handles multiple cooks' do
      cook_2 = create(:resident, community: community, unit: unit)

      update_bills(
        meal_id: meal.id,
        bills: [
          { resident_id: cook.id, amount: '30.00', no_cost: false },
          { resident_id: cook_2.id, amount: '20.00', no_cost: false }
        ]
      )

      expect(response).to have_http_status(:ok)
      expect(meal.bills.count).to eq(2)

      expect(meal.bills.find_by(resident: cook).amount).to eq(BigDecimal('30'))
      expect(meal.bills.find_by(resident: cook_2).amount).to eq(BigDecimal('20'))
    end

    it 'adds a new cook when a new resident_id is included' do
      new_cook = create(:resident, community: community, unit: unit)

      update_bills(
        meal_id: meal.id,
        bills: [
          { resident_id: cook.id, amount: '40.00', no_cost: false },
          { resident_id: new_cook.id, amount: '25.00', no_cost: false }
        ]
      )

      expect(response).to have_http_status(:ok)
      expect(meal.bills.count).to eq(2)
      expect(meal.bills.find_by(resident: new_cook).amount).to eq(BigDecimal('25'))
    end
  end

  describe 'no_cost bills' do
    it 'sets no_cost flag on the bill' do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: '0', no_cost: true }]
      )

      expect(response).to have_http_status(:ok)
      bill.reload
      expect(bill.no_cost).to be(true)
      expect(bill.amount).to eq(BigDecimal('0'))
    end

    it 'excludes no_cost bills from total_cost' do
      create(:meal_resident, meal: meal, resident: resident, community: community)
      paying_cook = create(:resident, community: community, unit: unit)

      update_bills(
        meal_id: meal.id,
        bills: [
          { resident_id: cook.id, amount: '0', no_cost: true },
          { resident_id: paying_cook.id, amount: '60.00', no_cost: false }
        ]
      )

      meal.reload
      expect(meal.total_cost).to eq(BigDecimal('60'))
    end
  end

  describe 'reconciled meal rejection' do
    let(:reconciliation) { create(:reconciliation, community: community) }

    before do
      meal.update!(reconciliation: reconciliation)
    end

    it 'returns 400 with an error message' do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: '50.00', no_cost: false }]
      )

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body['message']).to include('reconciled')
    end

    it 'does not modify the bill' do
      original_amount = bill.amount

      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: '999.00', no_cost: false }]
      )

      bill.reload
      expect(bill.amount).to eq(original_amount)
    end
  end

  describe 'blank amount' do
    it 'treats empty string amount as zero' do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: '', no_cost: false }]
      )

      expect(response).to have_http_status(:ok)
      bill.reload
      expect(bill.amount).to eq(BigDecimal('0'))
    end

    it 'treats nil amount as zero' do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: nil, no_cost: false }]
      )

      expect(response).to have_http_status(:ok)
      bill.reload
      expect(bill.amount).to eq(BigDecimal('0'))
    end
  end

  describe 'malformed amount' do
    it 'returns 400 for non-numeric strings' do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: 'abc', no_cost: false }]
      )

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body['message']).to include('Invalid amount')
    end

    it 'does not modify the bill' do
      bill.update!(amount: BigDecimal('25'))

      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: 'not-a-number', no_cost: false }]
      )

      bill.reload
      expect(bill.amount).to eq(BigDecimal('25'))
    end
  end

  describe 'authentication' do
    it 'returns 401 without a token' do
      patch "/api/v1/meals/#{meal.id}/bills", params: {
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: '50.00', no_cost: false }]
      }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['message']).to include('not authenticated')
    end

    it 'returns 401 with an invalid token' do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: '50.00', no_cost: false }],
        token: 'bogus-token-that-does-not-exist'
      )

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'authorization' do
    it 'returns 403 when resident belongs to a different community' do
      other_community = create(:community)
      other_unit = create(:unit, community: other_community)
      other_resident = create(:resident, community: other_community, unit: other_unit)

      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: '50.00', no_cost: false }],
        token: other_resident.key.token
      )

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'third-cook warnings' do
    let(:rotation) { create(:rotation, community: community) }
    let(:future_meal) { create(:meal, community: community, date: 1.week.from_now, rotation: rotation) }
    let(:other_meal) { create(:meal, community: community, date: 2.weeks.from_now, rotation: rotation) }

    let(:cook_1) { create(:resident, community: community, unit: unit) }
    let(:cook_2) { create(:resident, community: community, unit: unit) }
    let(:cook_3) { create(:resident, community: community, unit: unit) }
    let(:cook_4) { create(:resident, community: community, unit: unit) }

    before do
      # future_meal starts with 2 cooks
      create(:bill, meal: future_meal, resident: cook_1, community: community, amount: BigDecimal('0'))
      create(:bill, meal: future_meal, resident: cook_2, community: community, amount: BigDecimal('0'))
      # other_meal in the rotation has < 2 cooks (only 1)
      create(:bill, meal: other_meal, resident: cook_1, community: community, amount: BigDecimal('0'))
    end

    it 'warns when adding a 3rd cook' do
      update_bills(
        meal_id: future_meal.id,
        bills: [
          { resident_id: cook_1.id, amount: '10.00', no_cost: false },
          { resident_id: cook_2.id, amount: '10.00', no_cost: false },
          { resident_id: cook_3.id, amount: '0', no_cost: false }
        ]
      )

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body['message']).to include('Warning')
      expect(response.parsed_body['message']).to include('added')
      expect(response.parsed_body['type']).to eq('warning')
      # Bills are still saved despite the warning
      expect(future_meal.bills.count).to eq(3)
    end

    it 'warns when switching a 3rd cook' do
      # Add a 3rd cook first
      create(:bill, meal: future_meal, resident: cook_3, community: community, amount: BigDecimal('0'))

      update_bills(
        meal_id: future_meal.id,
        bills: [
          { resident_id: cook_1.id, amount: '10.00', no_cost: false },
          { resident_id: cook_2.id, amount: '10.00', no_cost: false },
          { resident_id: cook_4.id, amount: '0', no_cost: false }
        ]
      )

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body['message']).to include('Warning')
      expect(response.parsed_body['message']).to include('switched')
      expect(response.parsed_body['type']).to eq('warning')
      # Cook was switched despite the warning
      expect(future_meal.bills.find_by(resident: cook_4)).to be_present
    end

    it 'does not warn when only updating cost for existing 3rd cook' do
      # Add a 3rd cook first
      create(:bill, meal: future_meal, resident: cook_3, community: community, amount: BigDecimal('0'))

      update_bills(
        meal_id: future_meal.id,
        bills: [
          { resident_id: cook_1.id, amount: '10.00', no_cost: false },
          { resident_id: cook_2.id, amount: '10.00', no_cost: false },
          { resident_id: cook_3.id, amount: '25.00', no_cost: false }
        ]
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['message']).to eq('Form submitted.')
      expect(response.parsed_body).not_to have_key('type')
      cook_3_bill = future_meal.bills.find_by(resident: cook_3)
      cook_3_bill.reload
      expect(cook_3_bill.amount).to eq(BigDecimal('25'))
    end

    it 'does not warn when all rotation meals have 2+ cooks' do
      # Give other_meal a 2nd cook so rotation is fully staffed
      create(:bill, meal: other_meal, resident: cook_2, community: community, amount: BigDecimal('0'))

      update_bills(
        meal_id: future_meal.id,
        bills: [
          { resident_id: cook_1.id, amount: '10.00', no_cost: false },
          { resident_id: cook_2.id, amount: '10.00', no_cost: false },
          { resident_id: cook_3.id, amount: '0', no_cost: false }
        ]
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['message']).to eq('Form submitted.')
    end

    it 'does not warn for future meal with no rotation' do
      no_rotation_meal = create(:meal, community: community, date: 3.weeks.from_now)
      create(:bill, meal: no_rotation_meal, resident: cook_1, community: community, amount: BigDecimal('0'))
      create(:bill, meal: no_rotation_meal, resident: cook_2, community: community, amount: BigDecimal('0'))

      update_bills(
        meal_id: no_rotation_meal.id,
        bills: [
          { resident_id: cook_1.id, amount: '10.00', no_cost: false },
          { resident_id: cook_2.id, amount: '10.00', no_cost: false },
          { resident_id: cook_3.id, amount: '0', no_cost: false }
        ]
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['message']).to eq('Form submitted.')
    end

    it 'does not warn for past meals' do
      past_meal = create(:meal, community: community, date: 1.week.ago, rotation: rotation)
      create(:bill, meal: past_meal, resident: cook_1, community: community, amount: BigDecimal('0'))
      create(:bill, meal: past_meal, resident: cook_2, community: community, amount: BigDecimal('0'))

      update_bills(
        meal_id: past_meal.id,
        bills: [
          { resident_id: cook_1.id, amount: '10.00', no_cost: false },
          { resident_id: cook_2.id, amount: '10.00', no_cost: false },
          { resident_id: cook_3.id, amount: '0', no_cost: false }
        ]
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['message']).to eq('Form submitted.')
    end
  end

  describe 'meal not found' do
    it 'returns 404 for a nonexistent meal' do
      update_bills(
        meal_id: 999_999,
        bills: [{ resident_id: cook.id, amount: '50.00', no_cost: false }]
      )

      expect(response).to have_http_status(:not_found)
    end
  end
end
