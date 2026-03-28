# == Schema Information
#
# Table name: communities
#
#  id         :bigint           not null, primary key
#  cap        :decimal(12, 8)
#  name       :string           not null
#  slug       :string           not null
#  timezone   :string           default("America/Los_Angeles"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_communities_on_name  (name) UNIQUE
#  index_communities_on_slug  (slug) UNIQUE
#
require 'rails_helper'

RSpec.describe Community, type: :model do
  let(:community) { FactoryBot.create(:community, cap: BigDecimal("4.50")) }
  let(:unit) { FactoryBot.create(:unit, community: community) }

  describe '#unreconciled_ave_cost' do
    it 'returns average cost per adult for unreconciled meals' do
      cook = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      diner = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)

      meal = FactoryBot.create(:meal, community: community)
      FactoryBot.create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal("40"))
      FactoryBot.create(:meal_resident, meal: meal, resident: cook, community: community)
      FactoryBot.create(:meal_resident, meal: meal, resident: diner, community: community)

      result = community.unreconciled_ave_cost
      # total_multiplier = 2 + 2 = 4, total_cost = 40, cost_per_unit = 10, per_adult = 20
      expect(result).to eq("$20.00/adult")
    end

    it 'returns -- when no unreconciled meals exist' do
      expect(community.unreconciled_ave_cost).to eq('--')
    end

    it 'returns -- when total multiplier is zero' do
      child = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 0)
      meal = FactoryBot.create(:meal, community: community)
      FactoryBot.create(:bill, meal: meal, resident: child, community: community, amount: BigDecimal("10"))
      FactoryBot.create(:meal_resident, meal: meal, resident: child, community: community, multiplier: 0)

      expect(community.unreconciled_ave_cost).to eq('--')
    end
  end

  describe '#unreconciled_ave_number_of_attendees' do
    it 'returns average attendee count across unreconciled meals' do
      cook = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      diner = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)

      meal1 = FactoryBot.create(:meal, community: community)
      FactoryBot.create(:meal_resident, meal: meal1, resident: cook, community: community)
      FactoryBot.create(:meal_resident, meal: meal1, resident: diner, community: community)

      meal2 = FactoryBot.create(:meal, community: community)
      FactoryBot.create(:meal_resident, meal: meal2, resident: cook, community: community)

      # meal1: 2 attendees, meal2: 1 attendee, average = 1.5
      expect(community.unreconciled_ave_number_of_attendees).to eq(1.5)
    end

    it 'returns -- when no unreconciled meals exist' do
      expect(community.unreconciled_ave_number_of_attendees).to eq('--')
    end

    it 'counts guests in addition to residents' do
      cook = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      meal = FactoryBot.create(:meal, community: community)
      FactoryBot.create(:meal_resident, meal: meal, resident: cook, community: community)
      FactoryBot.create(:guest, meal: meal, resident: cook)

      # 1 resident + 1 guest = 2 attendees / 1 meal = 2.0
      expect(community.unreconciled_ave_number_of_attendees).to eq(2.0)
    end
  end

  describe '#capped?' do
    it 'returns true when cap is set' do
      expect(community.capped?).to be true
    end

    it 'returns false when cap is nil' do
      uncapped = FactoryBot.create(:community, cap: nil)
      expect(uncapped.capped?).to be false
    end
  end

  describe '#auto_rotation_length' do
    it 'calculates half the number of cookable adults' do
      4.times { FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2, can_cook: true) }
      2.times { FactoryBot.create(:resident, community: community, unit: unit, multiplier: 1, can_cook: true) }
      # 4 adults (multiplier >= 2) who can cook, divided by 2 = 2
      expect(community.auto_rotation_length).to eq(2)
    end
  end
end
