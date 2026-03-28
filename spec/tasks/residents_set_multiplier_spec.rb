require 'rails_helper'
require 'rake'

RSpec.describe 'residents:set_multiplier' do
  before(:all) do
    Rails.application.load_tasks
  end

  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }

  after do
    Rake::Task['residents:set_multiplier'].reenable
  end

  it 'sets multiplier to 0 for children under 5' do
    infant = FactoryBot.create(:resident, community: community, unit: unit,
                               birthday: 2.years.ago.to_date, multiplier: 2)

    Rake::Task['residents:set_multiplier'].invoke

    expect(infant.reload.multiplier).to eq(0)
  end

  it 'sets multiplier to 1 for children aged 5 to 11' do
    child = FactoryBot.create(:resident, community: community, unit: unit,
                              birthday: 8.years.ago.to_date, multiplier: 2)

    Rake::Task['residents:set_multiplier'].invoke

    expect(child.reload.multiplier).to eq(1)
  end

  it 'sets multiplier to 2 for residents aged 12 and up' do
    adult = FactoryBot.create(:resident, community: community, unit: unit,
                              birthday: 30.years.ago.to_date, multiplier: 0)

    Rake::Task['residents:set_multiplier'].invoke

    expect(adult.reload.multiplier).to eq(2)
  end

  it 'handles age boundary at exactly 5' do
    exactly_5 = FactoryBot.create(:resident, community: community, unit: unit,
                                  birthday: 5.years.ago.to_date, multiplier: 0)

    Rake::Task['residents:set_multiplier'].invoke

    expect(exactly_5.reload.multiplier).to eq(1)
  end

  it 'handles age boundary at exactly 12' do
    exactly_12 = FactoryBot.create(:resident, community: community, unit: unit,
                                   birthday: 12.years.ago.to_date, multiplier: 0)

    Rake::Task['residents:set_multiplier'].invoke

    expect(exactly_12.reload.multiplier).to eq(2)
  end

  it 'updates multiple residents in a single run' do
    infant = FactoryBot.create(:resident, community: community, unit: unit,
                               birthday: 1.year.ago.to_date, multiplier: 2)
    child = FactoryBot.create(:resident, community: community, unit: unit,
                              birthday: 7.years.ago.to_date, multiplier: 2)
    adult = FactoryBot.create(:resident, community: community, unit: unit,
                              birthday: 40.years.ago.to_date, multiplier: 0)

    Rake::Task['residents:set_multiplier'].invoke

    expect(infant.reload.multiplier).to eq(0)
    expect(child.reload.multiplier).to eq(1)
    expect(adult.reload.multiplier).to eq(2)
  end
end
