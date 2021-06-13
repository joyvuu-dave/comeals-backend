# == Schema Information
#
# Table name: resident_balances
#
#  id          :bigint           not null, primary key
#  amount      :integer          default(0), not null
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

  validates_numericality_of :amount, only_integer: true
end
