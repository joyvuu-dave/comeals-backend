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
FactoryBot.define do
  factory :reconciliation_balance do
    reconciliation
    resident
    amount { BigDecimal("0") }
  end
end
