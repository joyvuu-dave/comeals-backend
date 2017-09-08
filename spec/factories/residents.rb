FactoryGirl.define do
  factory :resident do
    community
    unit
    name { Faker::Seinfeld.character }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end
