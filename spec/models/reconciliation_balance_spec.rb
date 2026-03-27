require 'rails_helper'

RSpec.describe ReconciliationBalance, type: :model do
  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }

  describe 'associations' do
    it 'belongs to a reconciliation and resident' do
      resident = FactoryBot.create(:resident, community: community, unit: unit)
      reconciliation = FactoryBot.create(:reconciliation, community: community)
      balance = ReconciliationBalance.create!(
        reconciliation: reconciliation, resident: resident, amount: BigDecimal("42.50")
      )

      expect(balance.reconciliation).to eq(reconciliation)
      expect(balance.resident).to eq(resident)
    end
  end

  describe 'validations' do
    it 'enforces uniqueness of resident per reconciliation' do
      resident = FactoryBot.create(:resident, community: community, unit: unit)
      reconciliation = FactoryBot.create(:reconciliation, community: community)

      ReconciliationBalance.create!(
        reconciliation: reconciliation, resident: resident, amount: BigDecimal("10")
      )

      duplicate = ReconciliationBalance.new(
        reconciliation: reconciliation, resident: resident, amount: BigDecimal("20")
      )
      expect(duplicate).not_to be_valid
    end
  end

  describe 'amount precision' do
    it 'stores DECIMAL(12,8) values' do
      resident = FactoryBot.create(:resident, community: community, unit: unit)
      reconciliation = FactoryBot.create(:reconciliation, community: community)

      balance = ReconciliationBalance.create!(
        reconciliation: reconciliation, resident: resident, amount: BigDecimal("-123.45")
      )

      balance.reload
      expect(balance.amount).to eq(BigDecimal("-123.45"))
      expect(balance.amount).to be_a(BigDecimal)
    end
  end
end
