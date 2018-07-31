# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

start = Time.now

# Community
community = Community.create!(name: "Patches Way", cap: 250)
community.update!(slug: 'patches')

puts "1 Community created"

# AdminUser
admin_user = AdminUser.create!(email: 'joslyn@email.com', password: 'password', password_confirmation: 'password', community_id: community.id)

puts "#{community.admin_users.count} AdminUser created"

# Units / Residents
('A'..'Z').to_a.each_with_index do |letter, index|
  unless letter == 'O' || letter == 'I'
    unit = Unit.create!(name: letter, community_id: community.id)
    Resident.create!(name: "#{Faker::Name.first_name} #{Faker::Name.last_name}",
                    multiplier: 1, unit_id: unit.id, community_id: community.id, password: '', birthday: Date.new((Date.today.year - 10..Date.today.year - 1).to_a.shuffle.first, (1..12).to_a.shuffle.first, (1..28).to_a.shuffle.first)) if index % 5 == 0
    Resident.create!(name: "#{Faker::Name.first_name} #{Faker::Name.last_name}",
                    multiplier: 2, unit_id: unit.id, email: Faker::Internet.email, community_id: community.id, password: 'password', birthday: Date.new((Date.today.year - 90..Date.today.year - 20).to_a.shuffle.first, (1..12).to_a.shuffle.first, (1..28).to_a.shuffle.first))
    Resident.create!(name: "#{Faker::Name.first_name} #{Faker::Name.last_name}",
                    multiplier: 2, unit_id: unit.id, email: Faker::Internet.email, community_id: community.id, password: 'password', vegetarian: true, birthday: Date.new((Date.today.year - 90..Date.today.year - 20).to_a.shuffle.first, (1..12).to_a.shuffle.first, (1..28).to_a.shuffle.first)) if index % 2 == 0
  end
end

# Give 3 Residents the same First Name
first_name = Faker::Name.first_name
Resident.where(id: Resident.where(multiplier: 2).pluck(:id).shuffle.take(3)).each do |resident|
  resident.update!(name: "#{first_name} #{Faker::Name.last_name}")
end

# Make 1 (adult) Resident have a simple email address and matching name
Resident.where(multiplier: 2).first.update!(email: 'bowen@email.com', name: 'Bowen Riddle')

puts "#{community.units.count} Units created"
puts "#{community.residents.count} Residents created"

# Meals (will be reconciled)
Meal.create_templates(community.id, 26.weeks.ago.to_date, 8.weeks.ago.to_date, 0)

puts "#{community.meals.count} Meals created"

# MealResidents & Guests
Meal.all.each do |meal|
  next if meal.date > Date.today + 7
  Resident.all.shuffle[0..(Random.rand(8..21))].each_with_index do |resident, index|
    if index % 10 === 0
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
    else
      if index % 13 == 0
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
end

puts "#{community.guests.count} Guests created"
puts "#{community.meal_residents.count} MealResidents created"

# Bills
Meal.all.each_with_index do |meal, index|
  next if meal.date > Date.today + 14
  ids = Resident.pluck(:id).shuffle[0..1]
  if index % 2 == 0 && index % 3 == 0
    Bill.create(meal_id: meal.id, resident_id: ids[0],
                amount_cents: (3500..6500).to_a.shuffle[0], community_id: community.id)
    Bill.create(meal_id: meal.id, resident_id: ids[1],
                amount_cents: 0, community_id: community.id)
  elsif index % 2 == 0
    Bill.create(meal_id: meal.id, resident_id: ids[0],
                amount_cents: (2500..3500).to_a.shuffle[0], community_id: community.id)
    Bill.create(meal_id: meal.id, resident_id: ids[1],
                amount_cents: (3500..4500).to_a.shuffle[0], community_id: community.id)
  else
    Bill.create(meal_id: meal.id, resident_id: ids[0],
                amount_cents: (5500..6500).to_a.shuffle[0], community_id: community.id)
    Bill.create(meal_id: meal.id, resident_id: ids[1],
                amount_cents: (6500..7500).to_a.shuffle[0], community_id: community.id)
  end
end

puts "#{community.bills.count} Bills created"

# Reconciliation
Reconciliation.create!(community_id: community.id)
puts "#{community.reconciliations.count} Reconciliation created"


# Meals (will not be reconciled)
Meal.create_templates(community.id, 7.weeks.ago.to_date, 26.weeks.from_now.to_date, 0)

# MealResidents & Guests
Meal.all.each do |meal|
  next if meal.date > Date.today + 7
  Resident.all.shuffle[0..(Random.rand(8..21))].each_with_index do |resident, index|
    if index % 10 === 0
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
    else
      if index % 13 == 0
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
end

puts "#{community.guests.count} Guests created"
puts "#{community.meal_residents.count} MealResidents created"

# Bills
Meal.all.each_with_index do |meal, index|
  next if meal.date > Date.today + 14
  ids = Resident.pluck(:id).shuffle[0..1]
  if index % 3 == 0 && index % 4 == 0
    Bill.create(meal_id: meal.id, resident_id: ids[0],
                amount_cents: (3500..6500).to_a.shuffle[0], community_id: community.id)
    Bill.create(meal_id: meal.id, resident_id: ids[1],
                amount_cents: 0, community_id: community.id)
  elsif index % 3 == 0
    Bill.create(meal_id: meal.id, resident_id: ids[0],
                amount_cents: (2500..3500).to_a.shuffle[0], community_id: community.id)
    Bill.create(meal_id: meal.id, resident_id: ids[1],
                amount_cents: (3500..4500).to_a.shuffle[0], community_id: community.id)
  elsif index % 4 == 0
    Bill.create(meal_id: meal.id, resident_id: ids[0],
                amount_cents: (5500..6500).to_a.shuffle[0], community_id: community.id)
    Bill.create(meal_id: meal.id, resident_id: ids[1],
                amount_cents: (6500..7500).to_a.shuffle[0], community_id: community.id)
  end
end

puts "#{community.bills.count} Bills created"

# Set description
Meal.all.each do |meal|
  next if meal.date > Date.today + 14
  meal.update!(description: "#{Faker::Food.dish}, #{Faker::Food.ingredient}, and #{Faker::Dessert.flavor} #{Faker::Dessert.variety}")
end




# Set Max
Meal.all.each_with_index do |meal, index|
  if (meal.date < Date.today && index % 2 == 0) || (meal.date >= Date.today && meal.date <= Date.today + 3)
    meal.update!(closed: true)
    meal.update!(max: meal.attendees_count + rand(1..4))
  end
end

puts "#{community.meals.count} Meals created (#{community.meals.unreconciled.count} unreconciled)"


# Create Rotations
community.auto_create_rotations

puts "#{community.rotations.count} Rotations created"


# Event
Time.zone = community.timezone
Event.create!(community_id: community.id, title: "HOA Meeting", start_date: Time.new(Time.now.year, Time.now.month, Time.now.day, 20, 0, 0), end_date: Time.new(Time.now.year, Time.now.month, Time.now.day, 21, 30, 0))
Event.create!(community_id: community.id, title: "Swan's Anniversary", start_date: Time.new(Time.now.year, Time.now.month, 15, 1, 0, 0), allday: true)

puts "#{community.events.count} Event#{'s' unless Event.count == 1} created"


# GuestRoomReservation
Time.zone = community.timezone
GuestRoomReservation.create!(community_id: community.id, resident_id: Resident.adult.where(community_id: community.id).pluck(:id).shuffle.first, date: Date.today)

puts "#{community.guest_room_reservations.count} GuestRoomReservation#{'s' unless GuestRoomReservation.count == 1} created"


# CommonHouseReservation
Time.zone = community.timezone
CommonHouseReservation.create!(community_id: community.id, resident_id: Resident.adult.where(community_id: community.id).pluck(:id).shuffle.first,
  start_date: Time.new(Date.tomorrow.year, Date.tomorrow.month, Date.tomorrow.day, 10, 30, 0),
  end_date:   Time.new(Date.tomorrow.year, Date.tomorrow.month, Date.tomorrow.day, 14,  0, 0)
)

puts "#{community.common_house_reservations.count} CommonHouseReservation#{'s' unless CommonHouseReservation.count == 1} created"


# Analytics
puts "Seed records created in #{Time.now - start}s"
