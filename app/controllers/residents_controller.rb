class ResidentsController < ApplicationController
  # GET /residents/login (www)
  def login
  end

  # GET /residents/calendar (subdomains)
  def calendar
    @community = Community.find_by(slug: subdomain)
    @id = current_resident.id
  end

  # GET /residents/password-reset
  def password_reset
  end

  # GET /residents/password-reset/:token
  def password_new
    resident = Resident.find_by(reset_password_token: params[:token])
    @email = resident&.email
    @token = resident&.reset_password_token
  end

  # GET /ical
  def ical
    resident = Resident.find(params[:id])

    respond_to do |format|
      format.ics do

        require 'icalendar/tzinfo'
        tzid = "America/Los_Angeles"
        tz = TZInfo::Timezone.get tzid
        timezone = tz.ical_timezone DateTime.new 2017, 6, 1, 8, 0, 0

        cal = Icalendar::Calendar.new
        cal.add_timezone timezone

        cal.x_wr_calname = resident.community.name

        Bill.where(resident_id: resident.id).each do |bill|
          event = Icalendar::Event.new

          meal_date = bill.meal.date
          meal_date_time_start = DateTime.new(meal_date.year, meal_date.month, meal_date.day, meal_date.sunday? ? 18 : 19, 0)
          meal_date_time_end = DateTime.new(meal_date.year, meal_date.month, meal_date.day, meal_date.sunday? ? 20 : 21, 0)

          event.dtstart = Icalendar::Values::DateTime.new meal_date_time_start, 'tzid' => tzid
          event.dtend = Icalendar::Values::DateTime.new meal_date_time_end, 'tzid' => tzid
          event.summary = "Cook Com. Dinner"
          event.description = bill.meal.description
          cal.add_event(event)
        end

        MealResident.where(resident_id: resident.id).each do |mr|
          event = Icalendar::Event.new

          meal_date = mr.meal.date
          meal_date_time_start = DateTime.new(meal_date.year, meal_date.month, meal_date.day, meal_date.sunday? ? 18 : 19, 0)
          meal_date_time_end = DateTime.new(meal_date.year, meal_date.month, meal_date.day, meal_date.sunday? ? 20 : 21, 0)

          event.dtstart = Icalendar::Values::DateTime.new meal_date_time_start, 'tzid' => tzid
          event.dtend = Icalendar::Values::DateTime.new meal_date_time_end, 'tzid' => tzid
          event.summary = "Common Dinner"
          event.description = mr.meal.description
          cal.add_event(event) unless Bill.joins(:meal).where(resident_id: resident.id).where("meals.date = ?", mr.meal.date).present?
        end

        render plain: cal.to_ical, content_type: "text/calendar"
      end
    end
  end

end
