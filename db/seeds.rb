# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Community
community = Community.create!(name: "Swan's Way", cap: 250, rotation_length: 13)

puts "#{Community.count} Community created"

# AdminUser
admin_user = AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password', community_id: community.id)

puts "#{AdminUser.count} AdminUser created"

# Units / Residents
('A'..'Z').to_a.each_with_index do |letter, index|
  unless letter == 'O' || letter == 'I'
    unit = Unit.create!(name: letter, community_id: community.id)
    Resident.create!(name: "#{Faker::Name.first_name} #{Faker::Name.last_name}",
                    multiplier: 1, unit_id: unit.id, email: Faker::Internet.email, community_id: community.id, password: '')
    Resident.create!(name: "#{Faker::Name.first_name} #{Faker::Name.last_name}",
                    multiplier: 2, unit_id: unit.id, email: Faker::Internet.email, community_id: community.id, password: 'password')
    Resident.create!(name: "#{Faker::Name.first_name} #{Faker::Name.last_name}",
                    multiplier: 2, unit_id: unit.id, email: Faker::Internet.email, community_id: community.id, password: 'password', vegetarian: true)
  end
end

# Give 3 Residents the same First Name
first_name = Faker::Name.first_name
Resident.where(id: Resident.where(multiplier: 2).pluck(:id).shuffle.take(3)).each do |resident|
  resident.update_attributes(name: "#{first_name} #{Faker::Name.last_name}")
end

# Make 1 (adult) Resident have a simple email address
Resident.where(multiplier: 2).first.update_attributes(email: 'resident@example.com')

puts "#{Unit.count} Units created"
puts "#{Resident.count} Residents created"

# Meals (will be reconciled)
Meal.create_templates(community.id, 26.weeks.ago.to_date, 8.weeks.ago.to_date, 0, 0)

puts "#{Meal.count} Meals created"

# MealResidents & Guests
Meal.all.each do |meal|
  Resident.all.shuffle[0..(Random.rand(8..21))].each_with_index do |resident, index|
    if index % 10 === 0
      Guest.create!(name: "Guest #{resident.id}",
                   multiplier: 2,
                   resident_id: resident.id,
                   meal_id: meal.id)
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

puts "#{Guest.count} Guests created"
puts "#{MealResident.count} MealResidents created"

# Bills
Meal.all.each_with_index do |meal, index|
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

puts "#{Bill.count} Bills created"

# Reconciliation
Reconciliation.create!(community_id: community.id)
puts "#{Reconciliation.count} Reconciliation created"


# Meals (will not be reconciled)
Meal.create_templates(community.id, 7.weeks.ago.to_date, 13.weeks.from_now.to_date, 0, 0)

# MealResidents & Guests
Meal.all.each do |meal|
  Resident.all.shuffle[0..(Random.rand(8..21))].each_with_index do |resident, index|
    if index % 10 === 0
      Guest.create(name: "Guest #{resident.id}",
                   multiplier: 2,
                   resident_id: resident.id,
                   meal_id: meal.id)
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

puts "#{Guest.count} Guests created"
puts "#{MealResident.count} MealResidents created"

# Bills
Meal.all.each_with_index do |meal, index|
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

puts "#{Bill.count} Bills created"

# Set description
Meal.update_all(description: 'Tofu tacos, Sloppy Joe, Beet Salad, Sourdough Rolls, Chocolate Cake, Strawberries')




# Set Max
Meal.all.each_with_index do |meal, index|
  next if meal.bills_count == 0
  if meal.date < Date.today + 1 && index % 2 == 0
    meal.update_attribute(:closed, true)
    meal.update_attribute(:max, meal.attendees_count + rand(0..3))
  end
end

puts "#{Meal.count} Meals created (#{Meal.unreconciled.count} unreconciled)"
