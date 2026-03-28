FactoryBot.define do
  factory :admin_user do
    community
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    superuser { false }
  end
end
