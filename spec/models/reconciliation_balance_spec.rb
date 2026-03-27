# == Schema Information
#
# Table name: reconciliation_balances
#
#  id                :bigint           not null, primary key
#  amount            :decimal(12, 8)   default(0.0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  reconciliation_id :bigint           not null
#  resident_id       :bigint           not null
#
# Indexes
#
#  index_recon_balances_on_recon_id_and_resident_id    (reconciliation_id,resident_id) UNIQUE
#  index_reconciliation_balances_on_reconciliation_id  (reconciliation_id)
#  index_reconciliation_balances_on_resident_id        (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (reconciliation_id => reconciliations.id)
#  fk_rails_...  (resident_id => residents.id)
#
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
