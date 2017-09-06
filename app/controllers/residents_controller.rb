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
        cal = Icalendar::Calendar.new
        cal.x_wr_calname = resident.community.name

        Bill.where(resident_id: resident.id).each do |bill|
          event = Icalendar::Event.new
          event.dtstart = bill.meal.date
          event.summary = "Cook Com. Dinner"
          cal.add_event(event)
        end

        MealResident.where(resident_id: resident.id).each do |mr|
          event = Icalendar::Event.new
          event.dtstart = mr.meal.date
          event.summary = "Common Dinner"
          cal.add_event(event) unless Bill.joins(:meal).where(resident_id: resident.id).where("meals.date = ?", mr.meal.date).present?
        end

        render plain: cal.to_ical, content_type: "text/calendar"
      end
    end
  end

end
