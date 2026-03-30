# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

start = Time.zone.now

# Community
community = Community.create!(name: 'Patches Way', cap: BigDecimal('2.50'))
community.update!(slug: 'patches')

Rails.logger.debug '1 Community created'

# AdminUser
AdminUser.create!(email: 'joslyn@email.com', password: 'password', password_confirmation: 'password',
                  community_id: community.id)

Rails.logger.debug { "#{community.admin_users.count} AdminUser created" }

# Units / Residents
('A'..'Z').to_a.each_with_index do |letter, index|
  next if %w[O I].include?(letter)

  unit = Unit.create!(name: letter, community_id: community.id)
  if (index % 5).zero?
    child_year = ((Time.zone.today.year - 10)..(Time.zone.today.year - 1)).to_a.sample
    child_birthday = Date.new(child_year, (1..12).to_a.sample, (1..28).to_a.sample)
    Resident.create!(name: "#{Faker::Name.first_name} #{Faker::Name.last_name}",
                     multiplier: 1, unit_id: unit.id, community_id: community.id,
                     password: '', birthday: child_birthday)
  end
  adult_year = ((Time.zone.today.year - 90)..(Time.zone.today.year - 20)).to_a.sample
  adult_birthday = Date.new(adult_year, (1..12).to_a.sample, (1..28).to_a.sample)
  Resident.create!(name: "#{Faker::Name.first_name} #{Faker::Name.last_name}",
                   multiplier: 2, unit_id: unit.id, email: Faker::Internet.email,
                   community_id: community.id, password: 'password',
                   birthday: adult_birthday)
  next unless index.even?

  veg_year = ((Time.zone.today.year - 90)..(Time.zone.today.year - 20)).to_a.sample
  veg_birthday = Date.new(veg_year, (1..12).to_a.sample, (1..28).to_a.sample)
  Resident.create!(name: "#{Faker::Name.first_name} #{Faker::Name.last_name}",
                   multiplier: 2, unit_id: unit.id, email: Faker::Internet.email,
                   community_id: community.id, password: 'password',
                   vegetarian: true, birthday: veg_birthday)
end

Rails.logger.debug { "#{community.units.count} Units created" }

# Give 3 Residents the same First Name
first_name = Faker::Name.first_name
Resident.where(id: Resident.where(multiplier: 2).pluck(:id).shuffle.take(3)).find_each do |resident|
  resident.update!(name: "#{first_name} #{Faker::Name.last_name}")
end

# Make 1 (adult) Resident have a simple email address and matching name
Resident.where(multiplier: 2).first.update!(email: 'bowen@email.com', name: 'Bowen Riddle')

Rails.logger.debug { "#{community.residents.count} Residents created" }

# Meals (will be reconciled)
Meal.create_templates(community.id, 26.weeks.ago.to_date, 8.weeks.ago.to_date, 0)

Rails.logger.debug { "#{community.meals.count} Meals created" }

# MealResidents & Guests
Meal.find_each do |meal|
  next if meal.date > Time.zone.today + 7

  Resident.all.shuffle[0..(Random.rand(8..21))].each_with_index do |resident, index|
    if (index % 10).zero?
      num = Random.rand(1..3)
      if num == 1
        Guest.create!(name: "Guest #{resident.id}",
                      multiplier: 2,
                      vegetarian: true,
                      resident_id: resident.id,
                      meal_id: meal.id)
      else
        Guest.create!(name: "Guest #{resident.id}",
                      multiplier: 2,
                      vegetarian: false,
                      resident_id: resident.id,
                      meal_id: meal.id)
      end
    elsif (index % 13).zero?
      MealResident.create!(resident_id: resident.id,
                           meal_id: meal.id,
                           multiplier: resident.multiplier,
                           community_id: community.id,
                           late: true)
    else
      MealResident.create!(resident_id: resident.id,
                           meal_id: meal.id,
                           multiplier: resident.multiplier,
                           community_id: community.id)
    end
  end
end

Rails.logger.debug { "#{community.guests.count} Guests created" }
Rails.logger.debug { "#{community.meal_residents.count} MealResidents created" }

# Bills
Meal.all.each_with_index do |meal, index|
  next if meal.date > Time.zone.today + 14

  ids = Resident.pluck(:id).sample(2)
  if index.even? && (index % 3).zero?
    Bill.create(meal_id: meal.id, resident_id: ids[0],
                amount: BigDecimal((35..65).to_a.sample.to_s), community_id: community.id)
    Bill.create(meal_id: meal.id, resident_id: ids[1],
                amount: BigDecimal('0'), community_id: community.id)
  elsif index.even?
    Bill.create(meal_id: meal.id, resident_id: ids[0],
                amount: BigDecimal((25..35).to_a.sample.to_s), community_id: community.id)
    Bill.create(meal_id: meal.id, resident_id: ids[1],
                amount: BigDecimal((35..45).to_a.sample.to_s), community_id: community.id)
  else
    Bill.create(meal_id: meal.id, resident_id: ids[0],
                amount: BigDecimal((55..65).to_a.sample.to_s), community_id: community.id)
    Bill.create(meal_id: meal.id, resident_id: ids[1],
                amount: BigDecimal((65..75).to_a.sample.to_s), community_id: community.id)
  end
end

Rails.logger.debug { "#{community.bills.count} Bills created" }

# Reconciliation
Reconciliation.create!(community_id: community.id, date: Time.zone.today + 1.day)
Rails.logger.debug { "#{community.reconciliations.count} Reconciliation created" }

# Meals (will not be reconciled)
Meal.create_templates(community.id, 7.weeks.ago.to_date, 26.weeks.from_now.to_date, 0)

# MealResidents & Guests
Meal.find_each do |meal|
  next if meal.date > Time.zone.today + 7

  Resident.all.shuffle[0..(Random.rand(8..21))].each_with_index do |resident, index|
    if (index % 10).zero?
      num = Random.rand(1..3)
      if num == 1
        Guest.create!(name: "Guest #{resident.id}",
                      multiplier: 2,
                      vegetarian: true,
                      resident_id: resident.id,
                      meal_id: meal.id)
      else
        Guest.create!(name: "Guest #{resident.id}",
                      multiplier: 2,
                      vegetarian: false,
                      resident_id: resident.id,
                      meal_id: meal.id)
      end
    elsif (index % 13).zero?
      MealResident.create(resident_id: resident.id,
                          meal_id: meal.id,
                          multiplier: resident.multiplier,
                          community_id: community.id,
                          late: true)
    else
      MealResident.create(resident_id: resident.id,
                          meal_id: meal.id,
                          multiplier: resident.multiplier,
                          community_id: community.id)
    end
  end
end

Rails.logger.debug { "#{community.guests.count} Guests created" }
Rails.logger.debug { "#{community.meal_residents.count} MealResidents created" }

# Bills
Meal.all.each_with_index do |meal, index|
  next if meal.date > Time.zone.today + 14

  ids = Resident.pluck(:id).sample(2)
  if (index % 3).zero? && (index % 4).zero?
    Bill.create(meal_id: meal.id, resident_id: ids[0],
                amount: BigDecimal((35..65).to_a.sample.to_s), community_id: community.id)
    Bill.create(meal_id: meal.id, resident_id: ids[1],
                amount: BigDecimal('0'), community_id: community.id)
  elsif (index % 3).zero?
    Bill.create(meal_id: meal.id, resident_id: ids[0],
                amount: BigDecimal((25..35).to_a.sample.to_s), community_id: community.id)
    Bill.create(meal_id: meal.id, resident_id: ids[1],
                amount: BigDecimal((35..45).to_a.sample.to_s), community_id: community.id)
  elsif (index % 4).zero?
    Bill.create(meal_id: meal.id, resident_id: ids[0],
                amount: BigDecimal((55..65).to_a.sample.to_s), community_id: community.id)
    Bill.create(meal_id: meal.id, resident_id: ids[1],
                amount: BigDecimal((65..75).to_a.sample.to_s), community_id: community.id)
  end
end

Rails.logger.debug { "#{community.bills.count} Bills created" }

# Set description
Meal.find_each do |meal|
  next if meal.date > Time.zone.today + 14

  meal.update!(description: "#{Faker::Food.dish}, #{Faker::Food.ingredient}, and #{Faker::Dessert.flavor} #{Faker::Dessert.variety}")
end

# Set Max
Meal.all.each_with_index do |meal, index|
  if (meal.date < Time.zone.today && index.even?) || meal.date.between?(Time.zone.today, Time.zone.today + 3)
    meal.update!(closed: true)
    meal.update!(max: meal.attendees_count + rand(1..4))
  end
end

Rails.logger.debug { "#{community.meals.count} Meals created (#{community.meals.unreconciled.count} unreconciled)" }

# Create Rotations
community.auto_create_rotations

Rails.logger.debug { "#{community.rotations.count} Rotations created" }

# Event
Time.zone = community.timezone
today = Time.zone.today
Event.create!(community_id: community.id, title: 'HOA Meeting',
              start_date: Time.zone.local(today.year, today.month, today.day, 20, 0, 0),
              end_date: Time.zone.local(today.year, today.month, today.day, 21, 30, 0))
Event.create!(community_id: community.id, title: "Swan's Anniversary",
              start_date: Time.zone.local(Time.zone.now.year, Time.zone.now.month, 15, 1, 0, 0), allday: true)

Rails.logger.debug { "#{community.events.count} Event#{'s' unless Event.one?} created" }

# GuestRoomReservation
Time.zone = community.timezone
GuestRoomReservation.create!(community_id: community.id,
                             resident_id: Resident.adult.where(community_id: community.id).pluck(:id).sample,
                             date: Time.zone.today)

Rails.logger.debug do
  "#{community.guest_room_reservations.count} GuestRoomReservation#{'s' unless GuestRoomReservation.one?} created"
end

# CommonHouseReservation
Time.zone = community.timezone
tomorrow = Date.tomorrow
CommonHouseReservation.create!(
  community_id: community.id,
  resident_id: Resident.adult.where(community_id: community.id).pluck(:id).sample,
  start_date: Time.zone.local(tomorrow.year, tomorrow.month, tomorrow.day, 10, 30, 0),
  end_date: Time.zone.local(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0, 0)
)

Rails.logger.debug do
  "#{community.common_house_reservations.count} CommonHouseReservation#{'s' unless CommonHouseReservation.one?} created"
end

# Analytics
Rails.logger.debug { "Seed records created in #{Time.zone.now - start}s" }
