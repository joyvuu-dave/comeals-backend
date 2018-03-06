namespace :residents do

  desc "Notify residents they need to sign up for a meal."
  task notify: :environment do
    start_time = Time.current

    # Find all the rotations that start within the next week where we haven't already notified the residents
    Rotation.where("start_date > ?", Date.today).where("start_date < ?", Date.today + 1.week).where(residents_notified: false).find_each do |rotation|
      Rails.logger.info("Processing rotation #{rotation.id}: #{rotation.description}...")

      # For the given rotation, find the residents who aren't already signed up to cook
      meal_ids = rotation.meal_ids
      bill_ids = Bill.where(meal_id: meal_ids)

      # Signed Up Residents
      signed_up_residents_ids = Bill.joins(:resident).where(id: bill_ids).pluck("residents.id")

      community = rotation.community

      eligible_cooks_ids = community.residents.where(can_cook: true, active: true).where("multiplier >= 2").ids
      eligible_cooks = Resident.joins(:unit).where(id: eligible_cooks_ids).order("units.name")

      # Meals with less than 2 cooks
      open_meal_dates = Meal.order(:date).where(community_id: community.id, rotation_id: rotation.id).where("bills_count < ?", 2).pluck(:date)

      eligible_cooks.each do |resident|
        if !signed_up_residents_ids.include?(resident.id)
          ResidentMailer.rotation_signup_email(resident, rotation, open_meal_dates, community).deliver_now
        end
      end

      rotation.update(residents_notified: true)
    end

    total_time = Time.current - start_time
    Rails.logger.info("Resident Notification Complete in #{total_time}s.")
  end
end
