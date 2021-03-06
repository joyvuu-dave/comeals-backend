# == Schema Information
#
# Table name: reconciliations
#
#  id           :bigint           not null, primary key
#  date         :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#
# Indexes
#
#  index_reconciliations_on_community_id  (community_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#

class Reconciliation < ApplicationRecord
  has_many :meals, dependent: :nullify
  has_many :bills, through: :meals
  has_many :cooks, through: :bills, source: :resident
  belongs_to :community

  #before_create :set_date
  #after_commit :update_meals, on: :create

  # def set_date(day=Time.now)
  #   self.date = day
  # end

  # Add reconciliation_id to meals without a
  # reconciliation_id that have at least one
  # bill associated with them
  # def update_meals
  #   Meal.where(community_id: community_id).unreconciled.joins(:bills).update_all(reconciliation_id: id)
  # end

  def number_of_meals
    meals.count
  end

  def unique_cooks
    cooks.uniq
  end
end
