# == Schema Information
#
# Table name: rotations
#
#  id                 :bigint           not null, primary key
#  color              :string           not null
#  description        :string           default(""), not null
#  place_value        :integer
#  residents_notified :boolean          default(FALSE), not null
#  start_date         :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  community_id       :bigint           not null
#
# Indexes
#
#  index_rotations_on_community_id  (community_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#
require 'rails_helper'

RSpec.describe Rotation, type: :model do
  let(:community) { FactoryBot.create(:community) }

  describe '#set_place_value' do
    it 'assigns sequential place_values scoped to community' do
      r1 = FactoryBot.create(:rotation, community: community, no_email: true)
      r2 = FactoryBot.create(:rotation, community: community, no_email: true)

      expect(r1.reload.place_value).to eq(1)
      expect(r2.reload.place_value).to eq(2)
    end

    it 'does not renumber rotations in other communities' do
      other_community = FactoryBot.create(:community)
      other_rotation = FactoryBot.create(:rotation, community: other_community, no_email: true)
      original_place = other_rotation.reload.place_value

      # Creating a rotation in our community should not affect the other community
      FactoryBot.create(:rotation, community: community, no_email: true)

      expect(other_rotation.reload.place_value).to eq(original_place)
    end

    it 'reorders on destroy' do
      r1 = FactoryBot.create(:rotation, community: community, no_email: true)
      r2 = FactoryBot.create(:rotation, community: community, no_email: true)
      r3 = FactoryBot.create(:rotation, community: community, no_email: true)

      r2.destroy!
      expect(r1.reload.place_value).to eq(1)
      expect(r3.reload.place_value).to eq(2)
    end
  end

  describe '#set_color' do
    it 'cycles through colors without repeating recent ones' do
      colors = []
      6.times do
        r = FactoryBot.create(:rotation, community: community, no_email: true)
        colors << r.color
      end

      # No two consecutive rotations should share a color (within 4-color window)
      colors.each_cons(2) do |a, b|
        expect(a).not_to eq(b), "Consecutive rotations had same color: #{a}"
      end
    end
  end

  describe '#set_description' do
    it 'sets description to the date range of meals' do
      rotation = FactoryBot.create(:rotation, community: community, no_email: true)
      FactoryBot.create(:meal, community: community, rotation: rotation, date: Date.new(2026, 3, 1))
      FactoryBot.create(:meal, community: community, rotation: rotation, date: Date.new(2026, 3, 15))

      rotation.save!
      expect(rotation.reload.description).to include("2026")
    end
  end

  describe '#set_start_date' do
    it 'sets start_date from the first meal date' do
      rotation = FactoryBot.create(:rotation, community: community, no_email: true)
      FactoryBot.create(:meal, community: community, rotation: rotation, date: Date.new(2026, 4, 1))
      FactoryBot.create(:meal, community: community, rotation: rotation, date: Date.new(2026, 4, 15))

      rotation.save!
      expect(rotation.reload.start_date).to eq(Date.new(2026, 4, 1))
    end
  end

  describe '#meals_count' do
    it 'returns the number of meals in the rotation' do
      rotation = FactoryBot.create(:rotation, community: community, no_email: true)
      FactoryBot.create(:meal, community: community, rotation: rotation)
      FactoryBot.create(:meal, community: community, rotation: rotation)

      expect(rotation.meals_count).to eq(2)
    end
  end

  describe '#notify_residents' do
    let(:unit) { FactoryBot.create(:unit, community: community) }

    it 'does not send emails when no_email is true' do
      FactoryBot.create(:resident, community: community, unit: unit, email: 'test@example.com')
      expect {
        FactoryBot.create(:rotation, community: community, no_email: true)
      }.not_to change { ActionMailer::Base.deliveries.count }
    end

    it 'skips inactive residents' do
      FactoryBot.create(:resident, community: community, unit: unit, active: false)
      FactoryBot.create(:resident, community: community, unit: unit, active: true)

      expect {
        FactoryBot.create(:rotation, community: community, no_email: false)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
