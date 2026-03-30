# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'residents:notify' do
  before(:all) do
    Rails.application.load_tasks
  end

  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }

  after do
    Rake::Task['residents:notify'].reenable
  end

  # The Rotation model's after_save :set_start_date callback overwrites
  # start_date from the first meal's date. We must use update_columns
  # after creating meals to set it to the value we need for the query.
  def create_rotation_with_meals(community:, start_date:, residents_notified: false, meal_dates: nil)
    rotation = create(:rotation, community: community,
                                 residents_notified: residents_notified)
    dates = meal_dates || [start_date + 1.day]
    dates.each do |date|
      create(:meal, community: community, rotation: rotation, date: date)
    end
    rotation.update_columns(start_date: start_date, residents_notified: residents_notified)
    rotation
  end

  it 'sends signup emails to eligible cooks who have not signed up' do
    rotation = create_rotation_with_meals(community: community,
                                          start_date: Time.zone.today + 3.days)

    eligible = create(:resident, community: community, unit: unit,
                                 can_cook: true, active: true, multiplier: 2)

    Rake::Task['residents:notify'].invoke

    emails = ActionMailer::Base.deliveries
    expect(emails.map(&:to).flatten).to include(eligible.email)
    expect(emails.last.subject).to eq('Sign up to Cook')
    expect(rotation.reload.residents_notified).to be true
  end

  it 'does not email residents who are already signed up to cook' do
    rotation = create_rotation_with_meals(community: community,
                                          start_date: Time.zone.today + 3.days)
    meal = rotation.meals.first

    signed_up = create(:resident, community: community, unit: unit,
                                  can_cook: true, active: true, multiplier: 2)
    create(:bill, meal: meal, resident: signed_up, community: community)

    not_signed_up = create(:resident, community: community, unit: unit,
                                      can_cook: true, active: true, multiplier: 2)

    Rake::Task['residents:notify'].invoke

    recipients = ActionMailer::Base.deliveries.flat_map(&:to)
    expect(recipients).to include(not_signed_up.email)
    expect(recipients).not_to include(signed_up.email)
  end

  it 'excludes residents who cannot cook or are inactive' do
    create_rotation_with_meals(community: community,
                               start_date: Time.zone.today + 3.days)

    cannot_cook = create(:resident, community: community, unit: unit,
                                    can_cook: false, active: true, multiplier: 2)
    inactive = create(:resident, community: community, unit: unit,
                                 can_cook: true, active: false, multiplier: 2)
    child = create(:resident, community: community, unit: unit,
                              can_cook: true, active: true, multiplier: 1)

    Rake::Task['residents:notify'].invoke

    recipients = ActionMailer::Base.deliveries.flat_map(&:to)
    expect(recipients).not_to include(cannot_cook.email)
    expect(recipients).not_to include(inactive.email)
    expect(recipients).not_to include(child.email)
  end

  it 'correctly identifies open meals (fewer than 2 cooks)' do
    open_date = Time.zone.today + 4.days
    full_date = Time.zone.today + 5.days
    rotation = create_rotation_with_meals(community: community,
                                          start_date: Time.zone.today + 3.days,
                                          meal_dates: [open_date, full_date])

    open_meal = rotation.meals.find_by(date: open_date)
    full_meal = rotation.meals.find_by(date: full_date)

    cook1 = create(:resident, community: community, unit: unit)
    create(:bill, meal: open_meal, resident: cook1, community: community)

    cook2 = create(:resident, community: community, unit: unit)
    cook3 = create(:resident, community: community, unit: unit)
    create(:bill, meal: full_meal, resident: cook2, community: community)
    create(:bill, meal: full_meal, resident: cook3, community: community)

    eligible = create(:resident, community: community, unit: unit,
                                 can_cook: true, active: true, multiplier: 2)

    Rake::Task['residents:notify'].invoke

    email = ActionMailer::Base.deliveries.find { |e| e.to.include?(eligible.email) }
    expect(email).to be_present
  end

  it 'skips rotations that do not start within the next week' do
    rotation = create_rotation_with_meals(community: community,
                                          start_date: Time.zone.today + 2.weeks)
    create(:resident, community: community, unit: unit,
                      can_cook: true, active: true, multiplier: 2)

    Rake::Task['residents:notify'].invoke

    expect(ActionMailer::Base.deliveries).to be_empty
    expect(rotation.reload.residents_notified).to be false
  end

  it 'skips eligible cooks who have no email address' do
    rotation = create_rotation_with_meals(community: community,
                                          start_date: Time.zone.today + 3.days)

    with_email = create(:resident, community: community, unit: unit,
                                   can_cook: true, active: true, multiplier: 2)
    without_email = create(:resident, community: community, unit: unit,
                                      can_cook: true, active: true, multiplier: 2)
    without_email.update_column(:email, nil)

    Rake::Task['residents:notify'].invoke

    recipients = ActionMailer::Base.deliveries.flat_map(&:to)
    expect(recipients).to include(with_email.email)
    expect(recipients).not_to include(nil)
    expect(rotation.reload.residents_notified).to be true
  end

  it 'skips rotations already marked as notified' do
    create_rotation_with_meals(community: community,
                               start_date: Time.zone.today + 3.days,
                               residents_notified: true)
    create(:resident, community: community, unit: unit,
                      can_cook: true, active: true, multiplier: 2)

    Rake::Task['residents:notify'].invoke

    expect(ActionMailer::Base.deliveries).to be_empty
  end
end
