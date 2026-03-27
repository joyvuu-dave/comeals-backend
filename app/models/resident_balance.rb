# == Schema Information
#
# Table name: resident_balances
#
#  id          :bigint           not null, primary key
#  amount      :decimal(12, 8)   default(0.0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  resident_id :bigint           not null
#
# Indexes
#
#  index_resident_balances_on_resident_id  (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (resident_id => residents.id)
#
class ResidentBalance < ApplicationRecord
  belongs_to :resident

  validates :amount, numericality: true
end
