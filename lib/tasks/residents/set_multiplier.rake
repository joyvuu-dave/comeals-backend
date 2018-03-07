namespace :residents do

  desc "Automatically set residents' multiplier based on their age."
  task set_multiplier: :environment do
    start_time = Time.current

    Resident.find_each do |resident|
      age = resident.age

      resident.update_columns(multiplier: 0) if age < 5
      resident.update_columns(multiplier: 1) if age >= 5 && age < 12
      resident.update_columns(multiplier: 2) if age >= 12
    end

    total_time = Time.current - start_time
    Rails.logger.info("Residents' Multiplier Update Complete in #{total_time}s.")
  end
end
