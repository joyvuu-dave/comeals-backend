# == Schema Information
#
# Table name: communities
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  cap        :integer
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_communities_on_name  (name) UNIQUE
#  index_communities_on_slug  (slug) UNIQUE
#

FactoryGirl.define do
  factory :community do
    name { Faker::Company.name }
  end
end
