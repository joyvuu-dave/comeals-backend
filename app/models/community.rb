# == Schema Information
#
# Table name: communities
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  cap             :integer
#  rotation_length :integer
#  slug            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_communities_on_name  (name) UNIQUE
#  index_communities_on_slug  (slug) UNIQUE
#

class Community < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  validates :name, uniqueness: { case_sensitive: false }

  has_many :bills, dependent: :destroy
  has_many :community_managers, dependent: :destroy
  has_many :managers, through: :community_managers, dependent: :destroy
  has_many :meals, dependent: :destroy
  has_many :meal_residents, dependent: :destroy
  has_many :reconciliations, dependent: :destroy
  has_many :residents, dependent: :destroy
  has_many :guests, through: :residents, dependent: :destroy
  has_many :units, dependent: :destroy

  def cap
    read_attribute(:cap) || Float::INFINITY
  end

end
