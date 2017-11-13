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

class Community < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  validates :name, uniqueness: { case_sensitive: false }
  validates_length_of :slug, within: 3..40

  has_many :bills, dependent: :destroy
  has_many :meals, dependent: :destroy
  has_many :meal_residents, dependent: :destroy
  has_many :reconciliations, dependent: :destroy
  has_many :residents, dependent: :destroy
  has_many :guests, through: :residents, dependent: :destroy
  has_many :units, dependent: :destroy
  has_many :admin_users, dependent: :destroy
  has_many :rotations, dependent: :destroy
  has_many :events, dependent: :destroy

  accepts_nested_attributes_for :admin_users

  def cap
    read_attribute(:cap) || Float::INFINITY
  end

  # Report Methods
  def unreconciled_ave_cost
    val = 2 * ((meals.unreconciled.pluck(:cost).reduce(&:+).to_i / meals.unreconciled.reduce(0) { |sum, meal| sum + meal.multiplier }.to_f) / 100.to_f)
    val.to_f.nan? ? '--' : "$#{sprintf('%0.02f', val)}/adult"
  end

  def unreconciled_ave_number_of_attendees
    val = (meals.unreconciled.reduce(0) { |sum, meal| sum + meal.attendees_count } / meals.unreconciled.count.to_f).round(1)
    val.to_f.nan? ? '--' : val
  end

  def rotation_length
    residents.where("multiplier >= 2").where(can_cook: true).size / 2
  end

  def auto_create_rotations
    meals = Meal.where(community_id: id, rotation_id: nil).order(:date)
    rotation = nil
    meals.find_each do |meal|
      rotation = Rotation.create!(community_id: id, description: "#{meal.date.to_s} to #{meal.date.to_s}") if rotation.nil?
      meal.update!(rotation_id: rotation.id)
      rotation.update!(description: "#{rotation.meals.order(:date).first.date.to_s} to #{rotation.meals.order(:date).last.date.to_s}")
      rotation = nil if rotation.meals.count == rotation_length
    end
  end
end
