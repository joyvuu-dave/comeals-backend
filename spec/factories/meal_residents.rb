FactoryGirl.define do
  factory :meal_resident do
    meal
    resident
    community
    multiplier { 2 }
  end
end
