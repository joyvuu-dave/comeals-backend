# == Schema Information
#
# Table name: residents
#
#  id                   :bigint           not null, primary key
#  active               :boolean          default("true"), not null
#  balance_is_dirty     :boolean          default("true"), not null
#  bill_costs           :integer          default("0"), not null
#  bills_count          :integer          default("0"), not null
#  birthday             :date             default("1900-01-01"), not null
#  can_cook             :boolean          default("true"), not null
#  email                :string
#  multiplier           :integer          default("2"), not null
#  name                 :string           not null
#  password_digest      :string           not null
#  reset_password_token :string
#  vegetarian           :boolean          default("false"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  community_id         :bigint           not null
#  unit_id              :bigint           not null
#
# Indexes
#
#  index_residents_on_community_id           (community_id)
#  index_residents_on_email                  (email) UNIQUE
#  index_residents_on_name_and_community_id  (name,community_id) UNIQUE
#  index_residents_on_reset_password_token   (reset_password_token) UNIQUE
#  index_residents_on_unit_id                (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (unit_id => units.id)
#

FactoryBot.define do
  factory :resident do
    community
    unit
    name { Faker::TvShows::Seinfeld.unique.character }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end
