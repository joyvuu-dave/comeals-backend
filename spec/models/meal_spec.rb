# == Schema Information
#
# Table name: meals
#
#  id                        :bigint           not null, primary key
#  bills_count               :integer          default(0), not null
#  cap                       :integer
#  closed                    :boolean          default(FALSE), not null
#  closed_at                 :datetime
#  cost                      :integer          default(0), not null
#  date                      :date             not null
#  description               :text             default(""), not null
#  guests_count              :integer          default(0), not null
#  guests_multiplier         :integer          default(0), not null
#  max                       :integer
#  meal_residents_count      :integer          default(0), not null
#  meal_residents_multiplier :integer          default(0), not null
#  start_time                :datetime         not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  community_id              :bigint           not null
#  reconciliation_id         :bigint
#  rotation_id               :bigint
#
# Indexes
#
#  index_meals_on_community_id           (community_id)
#  index_meals_on_date_and_community_id  (date,community_id) UNIQUE
#  index_meals_on_reconciliation_id      (reconciliation_id)
#  index_meals_on_rotation_id            (rotation_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (reconciliation_id => reconciliations.id)
#  fk_rails_...  (rotation_id => rotations.id)
#

require 'rails_helper'

RSpec.describe Meal, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
