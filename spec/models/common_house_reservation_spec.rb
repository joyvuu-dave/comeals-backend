# == Schema Information
#
# Table name: common_house_reservations
#
#  id           :bigint           not null, primary key
#  community_id :bigint           not null
#  resident_id  :bigint           not null
#  start_date   :datetime         not null
#  end_date     :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  title        :string
#

require 'rails_helper'

RSpec.describe CommonHouseReservation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
