module Api
  module V1
    class ResidentsController < ApplicationController
      before_action :authenticate, only: [:show_id]

      # GET /api/v1/residents/id
      def show_id
        render json: current_resident.id
      end

      # POST /api/v1/residents/token { email: 'email', password: 'password' }
      def token
        # Kids aren't required to have email addresses;
        # this prevents those accounts from signing in
        if params[:email].blank?
          render json: { message: "Email required." }, status: :bad_request and return
        end

        resident = Resident.find_by(email: params[:email])
        if resident.blank?
          render json: { message: "No resident with email #{params[:email]}" }, status: :bad_request and return
        end

        if resident.present? && resident.authenticate(params[:password])
          render json: { token: resident.key.token, slug: resident.community.slug, community_id: resident.community.id, resident_id: resident.id } and return
        else
          render json: { message: "Incorrect password" }, status: :bad_request and return
        end
      end

      # POST /api/v1/residents/password-reset { email: 'email' }
      def password_reset
        resident = Resident.find_by(email: params[:email])

        unless resident.present?
          render json: { message: 'No resident with that email address.' }, status: :bad_request and return
        end

        resident.reset_password_token = SecureRandom.urlsafe_base64
        if resident.save
          ResidentMailer.password_reset_email(resident).deliver_now
          render json: { message: 'Check your email to reset your password.' } and return
        else
          render json: { message: 'Error. Please try again.' }, status: :bad_request and return
        end
      end

      # POST /api/v1/residents/password-reset/:token { password: 'password' }
      def password_new
        resident = Resident.find_by(reset_password_token: params[:token])

        unless resident.present?
          render json: { message: 'Error.' }, status: :bad_request and return
        end

        resident.password = params[:password]

        if resident.save
          render json: { message: 'Password was updated!' } and return
        else
          render json: { message: 'Invalid password.' }, status: :bad_request and return
        end
      end

      # GET api/v1/residents/:id/ical
      def ical
        resident = Resident.find(params[:id])

        respond_to do |format|
          format.ics do

            require 'icalendar/tzinfo'
            tzid = resident.community.timezone
            tz = TZInfo::Timezone.get tzid
            timezone = tz.ical_timezone DateTime.new 2017, 6, 1, 8, 0, 0

            cal = Icalendar::Calendar.new
            cal.add_timezone timezone

            cal.x_wr_calname = "My #{resident.community.name}"

            Bill.where(resident_id: resident.id).each do |bill|
              event = Icalendar::Event.new

              meal_date = bill.meal.date
              meal_date_time_start = DateTime.new(meal_date.year, meal_date.month, meal_date.day, meal_date.sunday? ? 18 : 19, 0)
              meal_date_time_end = DateTime.new(meal_date.year, meal_date.month, meal_date.day, meal_date.sunday? ? 20 : 21, 0)

              event.dtstart = Icalendar::Values::DateTime.new meal_date_time_start, 'tzid' => tzid
              event.dtend = Icalendar::Values::DateTime.new meal_date_time_end, 'tzid' => tzid
              event.summary = "Cook Common Dinner"
              event.description = "#{bill.meal.description}\n\n\n\nView here: #{host}#{bill.community.slug}.comeals#{top_level}/meals/#{bill.meal.id}/edit"
              cal.add_event(event)
            end

            MealResident.where(resident_id: resident.id).each do |mr|
              event = Icalendar::Event.new

              meal_date = mr.meal.date
              meal_date_time_start = DateTime.new(meal_date.year, meal_date.month, meal_date.day, meal_date.sunday? ? 18 : 19, 0)
              meal_date_time_end = DateTime.new(meal_date.year, meal_date.month, meal_date.day, meal_date.sunday? ? 20 : 21, 0)

              event.dtstart = Icalendar::Values::DateTime.new meal_date_time_start, 'tzid' => tzid
              event.dtend = Icalendar::Values::DateTime.new meal_date_time_end, 'tzid' => tzid
              event.summary = "Attend Common Dinner"
              event.description = "#{mr.meal.description}\n\n\n\nView here: #{host}#{mr.community.slug}.comeals#{top_level}/meals/#{mr.meal.id}/edit"
              cal.add_event(event) unless Bill.joins(:meal).where(resident_id: resident.id).where("meals.date = ?", mr.meal.date).present?
            end

            render plain: cal.to_ical, content_type: "text/calendar"
          end
        end
      end

      private
      def authenticate
        not_authenticated_api unless signed_in_resident?
      end

    end
  end
end
