# == Schema Information
#
# Table name: communities
#
#  id         :bigint           not null, primary key
#  cap        :integer
#  name       :string           not null
#  slug       :string           not null
#  timezone   :string           default("America/Los_Angeles"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_communities_on_name  (name) UNIQUE
#  index_communities_on_slug  (slug) UNIQUE
#

class Community < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  validates :name, uniqueness: { case_sensitive: false }
  validates_length_of :slug, within: 3..40

  has_many :bills, dependent: :destroy
  has_many :meals, dependent: :destroy
  has_many :meal_residents, dependent: :destroy
  has_many :reconciliations, dependent: :destroy
  has_many :residents, dependent: :destroy
  has_many :guests, through: :residents, dependent: :destroy
  has_many :units, dependent: :destroy
  has_many :admin_users, dependent: :destroy
  has_many :rotations, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :guest_room_reservations, dependent: :destroy
  has_many :common_house_reservations, dependent: :destroy

  accepts_nested_attributes_for :admin_users

  def cap
    read_attribute(:cap) || Float::INFINITY
  end

  # Report Methods
  def unreconciled_ave_cost
    val = 2 * ((meals.unreconciled.pluck(:cost).reduce(&:+).to_i / meals.unreconciled.reduce(0) { |sum, meal| sum + meal.multiplier }.to_f) / 100.to_f)
    val.to_f.nan? ? '--' : "$#{sprintf('%0.02f', val)}/adult"
  end

  def unreconciled_ave_number_of_attendees
    val = (meals.unreconciled.reduce(0) { |sum, meal| sum + meal.attendees_count } / meals.unreconciled.count.to_f).round(1)
    val.to_f.nan? ? '--' : val
  end

  def meals_per_rotation
    12
  end

  def permanent_meal_days
    [0, 4]
  end

  def alternating_meal_days
    [1, 2]
  end

  def auto_rotation_length
    residents.where("multiplier >= 2").where(can_cook: true).size / 2
  end

  def auto_create_rotations
    meals = Meal.where(community_id: id, rotation_id: nil).order(:date)
    rotation = nil
    meals.find_each do |meal|
      rotation = Rotation.create!(community_id: id, description: "#{meal.date.to_s} to #{meal.date.to_s}", no_email: true) if rotation.nil?
      meal.update!(rotation_id: rotation.id)
      rotation.update!(description: "#{rotation.meals.order(:date).first.date.to_s} to #{rotation.meals.order(:date).last.date.to_s}")
      rotation = nil if rotation.meals.count == auto_rotation_length
    end
  end

  def create_next_rotation
    raise "Currently #{Meal.where(rotation_id: nil).count} Meals not assigned to Rotations" if Meal.where(rotation_id: nil).count > 0

    day_after_last_meal = meals.order(:date).last&.date&.tomorrow
    current_date = day_after_last_meal.nil? ? Date.today : [Date.today, day_after_last_meal].max

    last_alternating_date = meals.where("extract(dow from date) = ?", alternating_meal_days[0])
                                 .or(
                            meals.where("extract(dow from date) = ?", alternating_meal_days[1]))
                                 .order(:date).last&.date
    if last_alternating_date.nil?
      last_alternating_date = current_date.beginning_of_week(Date::DAYNAMES[alternating_meal_days.last].downcase.to_sym) - 7
    end

    current_alternating_day = last_alternating_date.wday == alternating_meal_days[0] ? alternating_meal_days[1] : alternating_meal_days[0]

    rotation_meals = []
    until rotation_meals.length == meals_per_rotation do
      unless Meal.is_holiday?(current_date)
        if permanent_meal_days.include?(current_date.wday) || (current_date.wday == current_alternating_day && current_date.cweek != last_alternating_date.cweek)
          rotation_meals.push({ date: current_date, community_id: id })
        end
      end

      if current_date.wday == current_alternating_day && current_date.cweek != last_alternating_date.cweek
        last_alternating_date = current_date
        current_alternating_day = current_alternating_day == alternating_meal_days[0] ? alternating_meal_days[1] : alternating_meal_days[0]
      end
      current_date = current_date.tomorrow
    end

    Rotation.create!(community_id: id, meals_attributes: rotation_meals)
  end

  def trigger_pusher(date)
    ###############
    # CURRENT MONTH
    ###############
    key = "community-#{id}-calendar-#{date.year}-#{date.month}"

    # Delete Cache
    Rails.cache.delete(key)

    # Notify
    Pusher.trigger(
      key,
      'update',
      { message: 'current calendar month updated' }
    )


    ############
    # NEXT MONTH
    ############
    if date.end_of_week.month != date.month
      key = "community-#{id}-calendar-#{date.end_of_week.year}-#{date.end_of_week.month}"

      # Delete Cache
      Rails.cache.delete(key)

      # Notify
      Pusher.trigger(
        key,
        'update',
        { message: 'next calendar month updated' }
      )
    end


    ################
    # PREVIOUS MONTH
    ################
    range_start = ( (date.beginning_of_month - 1.day).beginning_of_month.beginning_of_week)
    range = (range_start..range_start + 41.days)

    if range.include?(date)
      key = "community-#{id}-calendar-#{(date.beginning_of_month - 1.day).year}-#{(date.beginning_of_month - 1.day).month}"

      # Delete Cache
      Rails.cache.delete(key)

      # Notify
      Pusher.trigger(
        key,
        'update',
        { message: 'previous calendar month updated' }
      )
    end

    return true
  end

end
