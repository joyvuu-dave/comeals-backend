FactoryGirl.define do
  factory :bill do
    meal
    resident
    community
    amount_cents { Random.rand(900..9900) }
  end
end
