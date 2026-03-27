FactoryBot.define do
  factory :rotation do
    community
    color { "blue" }
    no_email { true }
  end
end
