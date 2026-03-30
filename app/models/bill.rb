# frozen_string_literal: true

# == Schema Information
#
# Table name: bills
#
#  id           :bigint           not null, primary key
#  amount       :decimal(12, 8)   default(0.0), not null
#  no_cost      :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#  meal_id      :bigint           not null
#  resident_id  :bigint           not null
#
# Indexes
#
#  index_bills_on_community_id             (community_id)
#  index_bills_on_meal_id                  (meal_id)
#  index_bills_on_meal_id_and_resident_id  (meal_id,resident_id) UNIQUE
#  index_bills_on_resident_id              (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (meal_id => meals.id)
#  fk_rails_...  (resident_id => residents.id)
#
class Bill < ApplicationRecord
  belongs_to :meal, inverse_of: :bills, touch: true
  belongs_to :resident
  belongs_to :community

  audited associated_with: :meal

  delegate :date, to: :meal
  delegate :unit, to: :resident
  delegate :attendees_count, to: :meal

  before_validation :set_community_id

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :resident_id, uniqueness: { scope: :meal_id }

  def set_community_id
    self.community_id = meal&.community_id
  end

  # The amount used for cost-splitting purposes.
  # If no_cost is true, this cook's bill does not contribute to the meal cost.
  def effective_amount
    no_cost? ? BigDecimal('0') : amount
  end

  # Per-multiplier-unit cost for this bill.
  # Uses effective_amount so no_cost bills contribute 0.
  def unit_cost
    return BigDecimal('0') if meal.multiplier.zero?

    capped_amount / meal.multiplier
  end

  # The bill amount after applying the community cost cap.
  # If the meal is uncapped, returns the full effective_amount.
  # If capped, returns this bill's proportional share of the max cost.
  def capped_amount
    amt = effective_amount
    return amt unless persisted?
    return amt unless meal.capped?

    total = meal.total_cost
    return amt if total.zero?

    max = meal.max_cost
    return amt if total <= max

    (amt / total) * max
  end

  delegate :reconciled?, to: :meal
end
