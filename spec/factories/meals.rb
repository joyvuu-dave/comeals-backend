FactoryGirl.define do
  factory :meal do
    community
    date  { Faker::Date.backward(365) }
  end
end
