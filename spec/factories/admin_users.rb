# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user do
    community
    sequence(:email) { |n| "admin#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    superuser { false }
  end
end
