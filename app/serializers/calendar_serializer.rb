class CalendarSerializer < ActiveModel::Serializer
  attributes :id,
             :month,
             :year

  has_many :meals, serializer: MealSerializer
  has_many :bills, serializer: BillSerializer
  has_many :rotations, serializer: RotationSerializer
  has_many :birthdays, serializer: ResidentBirthdaySerializer
  has_many :common_house_reservations, serializer: CommonHouseReservationSerializer
  has_many :guest_room_reservations, serializer: GuestRoomReservationSerializer
  has_many :events, serializer: EventSerializer

  def id
    object.cache_key_with_version
  end

  def month
    instance_options[:month]
  end

  def year
    instance_options[:year]
  end

  def meals
    object.meals
          .where("date >= ?", instance_options[:start_date])
          .where("date <= ?", instance_options[:end_date])
  end

  def bills
    object.bills
          .includes(:meal, { :resident => :unit })
          .joins(:meal)
          .where("meals.date >= ?", instance_options[:start_date])
          .where("meals.date <= ?", instance_options[:end_date])
  end

  def rotations
    rotation_ids = meals.where.not(rotation_id: nil)
                        .pluck(:rotation_id).uniq
    Rotation.find(rotation_ids)
  end

  def birthdays
    object.residents.active.where("extract(month from birthday) in (?)", instance_options[:month_int_array])
  end

  def common_house_reservations
    object.common_house_reservations
          .includes({ :resident => :unit })
          .where("start_date >= ?", instance_options[:start_date])
          .where("start_date <= ?", instance_options[:end_date])
  end

  def guest_room_reservations
    object.guest_room_reservations
          .includes({ :resident => :unit })
          .where("date >= ?", instance_options[:start_date])
          .where("date <= ?", instance_options[:end_date])
  end

  def events
    object.events
          .where("start_date >= ?", instance_options[:start_date])
          .where("start_date <= ?", instance_options[:end_date])
          .or(object.events
                    .where("end_date >= ?", instance_options[:start_date])
                    .where("end_date <= ?", instance_options[:end_date]))
          .or(object.events
                    .where("start_date < ?", instance_options[:start_date])
                    .where("end_date > ?", instance_options[:end_date]))
  end

end
