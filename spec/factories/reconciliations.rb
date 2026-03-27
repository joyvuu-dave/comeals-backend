FactoryBot.define do
  factory :reconciliation do
    community
    date { Date.today }
  end
end
