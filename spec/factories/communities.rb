# == Schema Information
#
# Table name: communities
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  cap        :integer
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  timezone   :string           default("America/Los_Angeles"), not null
#
# Indexes
#
#  index_communities_on_name  (name) UNIQUE
#  index_communities_on_slug  (slug) UNIQUE
#

FactoryBot.define do
  factory :community do
    name { Faker::Company.name }
  end
end
