# == Schema Information
#
# Table name: bills
#
#  id              :bigint           not null, primary key
#  amount_cents    :integer          default("0"), not null
#  amount_currency :string           default("USD"), not null
#  no_cost         :boolean          default("false"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  community_id    :bigint           not null
#  meal_id         :bigint           not null
#  resident_id     :bigint           not null
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

  counter_culture :meal, column_name: 'bills_count'
  counter_culture :meal, column_name: 'cost', delta_column: 'amount_cents'
  counter_culture :resident, column_name: 'bills_count'
  counter_culture :resident, column_name: 'bill_costs', delta_column: 'amount_cents'

  delegate :multiplier, to: :meal
  delegate :date, to: :meal
  delegate :unit, to: :resident

  before_validation :set_community_id

  validates :meal, presence: true
  validates :resident, presence: true
  validates :community, presence: true
  validates :amount_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates_uniqueness_of :resident_id, scope: :meal_id

  monetize :amount_cents

  def set_community_id
    self.community_id = meal&.community_id
  end

  # DERIVED DATA
  def reimburseable_amount
    return 0 if amount_cents == 0
    return 0 if multiplier == 0

    value = max_amount
    until value % multiplier == 0 do
      value += 1
    end
    value
  end

  def unit_cost
    return 0 if multiplier == 0
    reimburseable_amount / multiplier
  end

  # HELPERS
  def max_amount
    return amount_cents unless persisted?
    return amount_cents if meal.cost == 0
    return amount_cents if meal.cap == Float::INFINITY

    ((amount_cents.to_f / meal.cost) * meal.max_cost).round
  end

  def reconciled?
    meal.reconciled?
  end
end
