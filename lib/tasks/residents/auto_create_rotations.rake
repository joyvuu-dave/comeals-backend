namespace :community do

  desc "Automatically create rotations so we always have 6 mo worth."
  task create_rotations: :environment do
    Rails.logger.info "Starting community:create_rotations"
    start_time = Time.current

    Community.find_each do |community|
      Rails.logger.info "Examining #{community.name}:#{community.id}"

      # We'll get into an infinite loop if there are
      # meals that aren't assigned to a rotation
      if community.meals.where(rotation_id: nil).present?
        Rails.logger.error "#{community.name}:#{community.id} has 1 or more meals that are not assigned to a rotation. Please fix before continuing."
        next
      else
        Rails.logger.info "#{community.name}:#{community.id} doesn't have any bad meals."
      end

      if community.meals.where("date >= ?", Date.today + 6.month).blank?
        Rails.logger.info "We need to create some meals..."
        count = 0

        while community.meals.where("date >= ?", Date.today + 6.month).blank? do
          Rails.logger.info "Creating rotation..."
          community.create_next_rotation
          Rails.logger.info "...rotation created."
          count += 1
        end

        Rails.logger.info("#{count} Rotations Created!")
      else
        Rails.logger.info "#{community.name}:#{community.id} was not in need of a new rotation."
      end
    end

    total_time = Time.current - start_time
    Rails.logger.info("community:create_rotations complete in #{total_time}s.")
  end
end
