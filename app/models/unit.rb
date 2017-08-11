# == Schema Information
#
# Table name: units
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  community_id    :integer          not null
#  residents_count :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_units_on_community_id           (community_id)
#  index_units_on_community_id_and_name  (community_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#

class Unit < ApplicationRecord
  has_many :residents, dependent: :destroy
  belongs_to :community

  validates_uniqueness_of :name, scope: :community_id

  # DERIVED DATA
  def balance
    return 0 if Meal.where(community_id: community_id).unreconciled.count == 0
    residents.reduce(0) { |sum, resident| sum + resident.balance }
  end

  def meals_cooked
    return 0 if Meal.where(community_id: community_id).unreconciled.count == 0
    residents.reduce(0) { |sum, resident| sum + resident.bills.joins(:meal).where({:meals => {:reconciliation_id =>  nil}}).count }
  end

  def number_of_occupants
    residents_count
  end
end
