FactoryBot.define do
  factory :reconciliation_balance do
    reconciliation
    resident
    amount { BigDecimal("0") }
  end
end
