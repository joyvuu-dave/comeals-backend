# == Schema Information
#
# Table name: resident_balances
#
#  id          :bigint           not null, primary key
#  resident_id :bigint           not null
#  amount      :decimal(12, 8)   default(0.0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class ResidentBalance < ApplicationRecord
  belongs_to :resident

  validates :amount, numericality: true
end
