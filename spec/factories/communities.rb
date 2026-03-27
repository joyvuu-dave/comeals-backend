# == Schema Information
#
# Table name: communities
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  cap        :decimal(12, 8)
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  timezone   :string           default("America/Los_Angeles"), not null
#

FactoryBot.define do
  factory :community do
    name { Faker::Company.unique.name }
  end
end
