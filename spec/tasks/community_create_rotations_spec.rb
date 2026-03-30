# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'community:create_rotations' do
  before(:all) do
    Rails.application.load_tasks
  end

  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }

  after do
    Rake::Task['community:create_rotations'].reenable
  end

  it 'creates rotations until meals exist 6 months out' do
    # Community needs at least one resident for meal scheduling context
    create(:resident, community: community, unit: unit)

    expect(community.meals.count).to eq(0)

    Rake::Task['community:create_rotations'].invoke

    expect(community.rotations.count).to be > 0
    expect(community.meals.count).to be > 0
    expect(community.meals.where(date: (Time.zone.today + 6.months)..).count).to be > 0
  end

  it 'does not create rotations when meals already extend 6 months out' do
    rotation = create(:rotation, community: community)
    create(:meal, community: community, rotation: rotation,
                  date: Time.zone.today + 7.months)

    initial_rotation_count = community.rotations.count

    Rake::Task['community:create_rotations'].invoke

    expect(community.rotations.count).to eq(initial_rotation_count)
  end

  it 'skips communities with unassigned meals' do
    # Create a meal with no rotation — this should block rotation creation
    create(:meal, community: community, rotation: nil)

    Rake::Task['community:create_rotations'].invoke

    # Only the orphan meal should exist — no new rotations created
    expect(community.rotations.count).to eq(0)
  end

  it 'creates meals that skip holidays' do
    create(:resident, community: community, unit: unit)

    Rake::Task['community:create_rotations'].invoke

    meal_dates = community.meals.pluck(:date)
    # Easter 2026 is April 5 (Sunday) and Mother's Day 2026 is May 10 (Sunday).
    # Both are permanent meal days (Sunday = day 0) and within the 6-month window.
    # If the holiday check is removed, meals WOULD be created on these dates.
    easter = Date.new(2026, 4, 5)
    mothers_day = Date.new(2026, 5, 10)
    expect(meal_dates).not_to include(easter)
    expect(meal_dates).not_to include(mothers_day)
    # Verify meals exist on adjacent Sundays so the check isn't vacuous
    expect(meal_dates.any? { |d| d.sunday? && d.month == 4 }).to be true
    expect(meal_dates.any? { |d| d.sunday? && d.month == 5 }).to be true
  end
end
