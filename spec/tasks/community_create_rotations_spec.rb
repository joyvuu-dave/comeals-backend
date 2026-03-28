require 'rails_helper'
require 'rake'

RSpec.describe 'community:create_rotations' do
  before(:all) do
    Rails.application.load_tasks
  end

  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }

  after do
    Rake::Task['community:create_rotations'].reenable
  end

  it 'creates rotations until meals exist 6 months out' do
    # Community needs at least one resident for meal scheduling context
    FactoryBot.create(:resident, community: community, unit: unit)

    expect(community.meals.count).to eq(0)

    Rake::Task['community:create_rotations'].invoke

    expect(community.rotations.count).to be > 0
    expect(community.meals.count).to be > 0
    expect(community.meals.where("date >= ?", Date.today + 6.months).count).to be > 0
  end

  it 'does not create rotations when meals already extend 6 months out' do
    rotation = FactoryBot.create(:rotation, community: community)
    FactoryBot.create(:meal, community: community, rotation: rotation,
                      date: Date.today + 7.months)

    initial_rotation_count = community.rotations.count

    Rake::Task['community:create_rotations'].invoke

    expect(community.rotations.count).to eq(initial_rotation_count)
  end

  it 'skips communities with unassigned meals' do
    # Create a meal with no rotation — this should block rotation creation
    FactoryBot.create(:meal, community: community, rotation: nil)

    Rake::Task['community:create_rotations'].invoke

    # Only the orphan meal should exist — no new rotations created
    expect(community.rotations.count).to eq(0)
  end

  it 'creates meals that skip holidays' do
    FactoryBot.create(:resident, community: community, unit: unit)

    Rake::Task['community:create_rotations'].invoke

    meal_dates = community.meals.pluck(:date)
    christmas_dates = meal_dates.select { |d| d.month == 12 && d.day == 25 }
    new_years_dates = meal_dates.select { |d| d.month == 1 && d.day == 1 }

    expect(christmas_dates).to be_empty
    expect(new_years_dates).to be_empty
  end
end
