# == Schema Information
#
# Table name: events
#
#  id           :bigint           not null, primary key
#  allday       :boolean          default(FALSE), not null
#  description  :string           default(""), not null
#  end_date     :datetime
#  start_date   :datetime         not null
#  title        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#
# Indexes
#
#  index_events_on_community_id  (community_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#

require 'rails_helper'

RSpec.describe Event, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
