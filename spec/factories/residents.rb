# == Schema Information
#
# Table name: residents
#
#  id                   :bigint           not null, primary key
#  name                 :string           not null
#  email                :string
#  community_id         :bigint           not null
#  unit_id              :bigint           not null
#  vegetarian           :boolean          default(FALSE), not null
#  bills_count          :integer          default(0), not null
#  multiplier           :integer          default(2), not null
#  password_digest      :string           not null
#  reset_password_token :string
#  can_cook             :boolean          default(TRUE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  active               :boolean          default(TRUE), not null
#  birthday             :date             default(Mon, 01 Jan 1900), not null
#

FactoryBot.define do
  factory :resident do
    community
    unit
    sequence(:name) { |n| "#{Faker::Name.first_name} #{Faker::Name.last_name} #{n}" }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end
