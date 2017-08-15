# == Schema Information
#
# Table name: resident_balances
#
#  id          :integer          not null, primary key
#  resident_id :integer          not null
#  amount      :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
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
