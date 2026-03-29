require 'rails_helper'

RSpec.describe "PATCH /api/v1/meals/:meal_id/bills", type: :request do
  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }
  let(:resident) { FactoryBot.create(:resident, community: community, unit: unit) }
  let(:token) { resident.key.token }
  let(:meal) { FactoryBot.create(:meal, community: community, date: Date.yesterday) }
  let(:cook) { FactoryBot.create(:resident, community: community, unit: unit) }
  let!(:bill) { FactoryBot.create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal("0")) }

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

  describe "successful bill update" do
    it "updates bill amounts and returns 200" do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: "75.50", no_cost: false }]
      )

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Form submitted.")

      bill.reload
      expect(bill.amount).to eq(BigDecimal("75.50"))
      expect(bill.no_cost).to eq(false)
    end

    it "stores amount as BigDecimal with full precision" do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: "50.01", no_cost: false }]
      )

      bill.reload
      expect(bill.amount).to be_a(BigDecimal)
      expect(bill.amount).to eq(BigDecimal("50.01"))
    end

    it "handles multiple cooks" do
      cook_2 = FactoryBot.create(:resident, community: community, unit: unit)

      update_bills(
        meal_id: meal.id,
        bills: [
          { resident_id: cook.id, amount: "30.00", no_cost: false },
          { resident_id: cook_2.id, amount: "20.00", no_cost: false }
        ]
      )

      expect(response).to have_http_status(:ok)
      expect(meal.bills.count).to eq(2)

      expect(meal.bills.find_by(resident: cook).amount).to eq(BigDecimal("30"))
      expect(meal.bills.find_by(resident: cook_2).amount).to eq(BigDecimal("20"))
    end

    it "adds a new cook when a new resident_id is included" do
      new_cook = FactoryBot.create(:resident, community: community, unit: unit)

      update_bills(
        meal_id: meal.id,
        bills: [
          { resident_id: cook.id, amount: "40.00", no_cost: false },
          { resident_id: new_cook.id, amount: "25.00", no_cost: false }
        ]
      )

      expect(response).to have_http_status(:ok)
      expect(meal.bills.count).to eq(2)
      expect(meal.bills.find_by(resident: new_cook).amount).to eq(BigDecimal("25"))
    end
  end

  describe "no_cost bills" do
    it "sets no_cost flag on the bill" do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: "0", no_cost: true }]
      )

      expect(response).to have_http_status(:ok)
      bill.reload
      expect(bill.no_cost).to eq(true)
      expect(bill.amount).to eq(BigDecimal("0"))
    end

    it "excludes no_cost bills from total_cost" do
      FactoryBot.create(:meal_resident, meal: meal, resident: resident, community: community)
      paying_cook = FactoryBot.create(:resident, community: community, unit: unit)

      update_bills(
        meal_id: meal.id,
        bills: [
          { resident_id: cook.id, amount: "0", no_cost: true },
          { resident_id: paying_cook.id, amount: "60.00", no_cost: false }
        ]
      )

      meal.reload
      expect(meal.total_cost).to eq(BigDecimal("60"))
    end
  end

  describe "reconciled meal rejection" do
    let(:reconciliation) { FactoryBot.create(:reconciliation, community: community) }

    before do
      meal.update!(reconciliation: reconciliation)
    end

    it "returns 400 with an error message" do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: "50.00", no_cost: false }]
      )

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to include("reconciled")
    end

    it "does not modify the bill" do
      original_amount = bill.amount

      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: "999.00", no_cost: false }]
      )

      bill.reload
      expect(bill.amount).to eq(original_amount)
    end
  end

  describe "blank amount" do
    it "treats empty string amount as zero" do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: "", no_cost: false }]
      )

      expect(response).to have_http_status(:ok)
      bill.reload
      expect(bill.amount).to eq(BigDecimal("0"))
    end

    it "treats nil amount as zero" do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: nil, no_cost: false }]
      )

      expect(response).to have_http_status(:ok)
      bill.reload
      expect(bill.amount).to eq(BigDecimal("0"))
    end
  end

  describe "malformed amount" do
    it "returns 400 for non-numeric strings" do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: "abc", no_cost: false }]
      )

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).to include("Invalid amount")
    end

    it "does not modify the bill" do
      bill.update!(amount: BigDecimal("25"))

      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: "not-a-number", no_cost: false }]
      )

      bill.reload
      expect(bill.amount).to eq(BigDecimal("25"))
    end
  end

  describe "authentication" do
    it "returns 401 without a token" do
      patch "/api/v1/meals/#{meal.id}/bills", params: {
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: "50.00", no_cost: false }]
      }

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["message"]).to include("not authenticated")
    end

    it "returns 401 with an invalid token" do
      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: "50.00", no_cost: false }],
        token: "bogus-token-that-does-not-exist"
      )

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "authorization" do
    it "returns 403 when resident belongs to a different community" do
      other_community = FactoryBot.create(:community)
      other_unit = FactoryBot.create(:unit, community: other_community)
      other_resident = FactoryBot.create(:resident, community: other_community, unit: other_unit)

      update_bills(
        meal_id: meal.id,
        bills: [{ resident_id: cook.id, amount: "50.00", no_cost: false }],
        token: other_resident.key.token
      )

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "meal not found" do
    it "returns 404 for a nonexistent meal" do
      update_bills(
        meal_id: 999999,
        bills: [{ resident_id: cook.id, amount: "50.00", no_cost: false }]
      )

      expect(response).to have_http_status(:not_found)
    end
  end
end
