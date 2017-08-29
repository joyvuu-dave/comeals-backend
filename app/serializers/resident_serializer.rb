# == Schema Information
#
# Table name: residents
#
#  id                   :integer          not null, primary key
#  name                 :string           not null
#  email                :string
#  community_id         :integer          not null
#  unit_id              :integer          not null
#  vegetarian           :boolean          default(FALSE), not null
#  bill_costs           :integer          default(0), not null
#  bills_count          :integer          default(0), not null
#  multiplier           :integer          default(2), not null
#  password_digest      :string           not null
#  reset_password_token :string
#  balance_is_dirty     :boolean          default(TRUE), not null
#  can_cook             :boolean          default(TRUE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_residents_on_community_id           (community_id)
#  index_residents_on_email                  (email) UNIQUE
#  index_residents_on_name_and_community_id  (name,community_id) UNIQUE
#  index_residents_on_reset_password_token   (reset_password_token) UNIQUE
#  index_residents_on_unit_id                (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (unit_id => units.id)
#

class ResidentSerializer < ActiveModel::Serializer
  cache key: 'resident'
  attributes :name,
             :balance,
             :meals_attended

  def balance
    ActionController::Base.helpers.number_to_currency(object.balance / 100.to_f)
  end
end
