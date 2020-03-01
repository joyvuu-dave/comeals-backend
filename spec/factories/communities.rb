# == Schema Information
#
# Table name: communities
#
#  id         :bigint           not null, primary key
#  cap        :integer
#  name       :string           not null
#  slug       :string           not null
#  timezone   :string           default("America/Los_Angeles"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_communities_on_name  (name) UNIQUE
#  index_communities_on_slug  (slug) UNIQUE
#

FactoryBot.define do
  factory :community do
    name { Faker::Company.unique.name }
  end
end
