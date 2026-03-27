# == Schema Information
#
# Table name: events
#
#  id           :bigint           not null, primary key
#  title        :string           not null
#  description  :string           default(""), not null
#  start_date   :datetime         not null
#  end_date     :datetime
#  allday       :boolean          default(FALSE), not null
#  community_id :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Event, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
