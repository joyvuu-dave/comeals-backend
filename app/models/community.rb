# frozen_string_literal: true

# == Schema Information
#
# Table name: communities
#
#  id         :bigint           not null, primary key
#  cap        :decimal(12, 8)
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
  # Ransack allowlists for ActiveAdmin sorting
  def self.ransackable_attributes(_auth_object = nil)
    %w[id cap name slug timezone created_at updated_at]
  end

  extend FriendlyId

  friendly_id :name, use: :slugged
  validates :name, uniqueness: { case_sensitive: false }
  validates :slug, length: { within: 3..40 }

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

  # NULL cap means "no cap"
  def cap
    read_attribute(:cap)
  end

  def capped?
    cap.present?
  end

  # Report Methods
  def unreconciled_ave_cost
    unreconciled = meals.unreconciled.preload(:bills, :meal_residents, :guests).to_a
    total_multiplier = unreconciled.sum do |meal|
      meal.meal_residents.sum(&:multiplier) + meal.guests.sum(&:multiplier)
    end
    return '--' if total_multiplier.zero?

    total_cost = unreconciled.sum do |meal|
      meal.bills.reject(&:no_cost).sum(BigDecimal('0'), &:amount)
    end
    val = 2 * (total_cost / total_multiplier)
    "$#{format('%0.02f', val)}/adult"
  end

  def unreconciled_ave_number_of_attendees
    unreconciled = meals.unreconciled
    meal_count = unreconciled.count
    return '--' if meal_count.zero?

    mr_count = MealResident.where(meal_id: unreconciled.select(:id)).count
    g_count = Guest.where(meal_id: unreconciled.select(:id)).count
    ((mr_count + g_count).to_f / meal_count).round(1)
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
    residents.where('multiplier >= 2').where(can_cook: true).size / 2
  end

  def auto_create_rotations
    meals = Meal.where(community_id: id, rotation_id: nil).order(:date)
    rotation = nil
    meals.find_each do |meal|
      if rotation.nil?
        rotation = Rotation.create!(community_id: id, description: "#{meal.date} to #{meal.date}",
                                    no_email: true)
      end
      meal.update!(rotation_id: rotation.id)
      first_date = rotation.meals.order(:date).first.date
      last_date = rotation.meals.order(:date).last.date
      rotation.update!(description: "#{first_date} to #{last_date}")
      rotation = nil if rotation.meals.count == auto_rotation_length
    end
  end

  def create_next_rotation # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity -- rotation scheduling with date arithmetic and alternating-day logic
    if Meal.where(rotation_id: nil).any?
      raise "Currently #{Meal.where(rotation_id: nil).count} Meals not assigned to Rotations"
    end

    day_after_last_meal = meals.order(:date).last&.date&.tomorrow
    current_date = day_after_last_meal.nil? ? Time.zone.today : [Time.zone.today, day_after_last_meal].max

    last_alternating_date = meals.where('extract(dow from date) = ?', alternating_meal_days[0])
                                 .or(
                                   meals.where('extract(dow from date) = ?', alternating_meal_days[1])
                                 )
                                 .order(:date).last&.date
    if last_alternating_date.nil?
      day_sym = Date::DAYNAMES[alternating_meal_days.last].downcase.to_sym
      last_alternating_date = current_date.beginning_of_week(day_sym) - 7
    end

    current_alternating_day = if last_alternating_date.wday == alternating_meal_days[0]
                                alternating_meal_days[1]
                              else
                                alternating_meal_days[0]
                              end

    rotation_meals = []
    until rotation_meals.length == meals_per_rotation
      is_permanent = permanent_meal_days.include?(current_date.wday)
      is_alternating = current_date.wday == current_alternating_day &&
                       current_date.cweek != last_alternating_date.cweek
      if !Meal.is_holiday?(current_date) && (is_permanent || is_alternating)
        rotation_meals.push({ date: current_date, community_id: id })
      end

      if current_date.wday == current_alternating_day && current_date.cweek != last_alternating_date.cweek
        last_alternating_date = current_date
        current_alternating_day = if current_alternating_day == alternating_meal_days[0]
                                    alternating_meal_days[1]
                                  else
                                    alternating_meal_days[0]
                                  end
      end
      current_date = current_date.tomorrow
    end

    Rotation.create!(community_id: id, meals_attributes: rotation_meals)
  end

  def trigger_pusher(date) # rubocop:disable Metrics/MethodLength -- builds multiple Pusher channel payloads
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
    range_start = (date.beginning_of_month - 1.day).beginning_of_month.beginning_of_week

    if date.between?(range_start, range_start + 41.days)
      prev_month = date.beginning_of_month - 1.day
      key = "community-#{id}-calendar-#{prev_month.year}-#{prev_month.month}"

      # Delete Cache
      Rails.cache.delete(key)

      # Notify
      Pusher.trigger(
        key,
        'update',
        { message: 'previous calendar month updated' }
      )
    end

    true
  end
end
