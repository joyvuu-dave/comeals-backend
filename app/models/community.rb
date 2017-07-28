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
  has_many :community_admin_users, dependent: :destroy
  has_many :admin_users, through: :community_admin_users

  def cap
    read_attribute(:cap) || Float::INFINITY
  end

  # Report Methods
  def unreconciled_ave_cost
    val = 2 * ((meals.unreconciled.pluck(:cost).reduce(&:+).to_i / meals.unreconciled.reduce(0) { |sum, meal| sum + meal.multiplier }.to_f) / 100.to_f)
    val.nan? ? '--' : "$#{sprintf('%0.02f', val)}/adult"
  end

  def unreconciled_ave_number_of_attendees
    val = (meals.unreconciled.reduce(0) { |sum, meal| sum + meal.attendees_count } / meals.unreconciled.count.to_f).round(1)
    val.nan? ? '--' : val
  end

end
