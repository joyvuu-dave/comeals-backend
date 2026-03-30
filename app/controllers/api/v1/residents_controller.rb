# frozen_string_literal: true

module Api
  module V1
    class ResidentsController < ApiController
      include ApplicationHelper

      before_action :authenticate, only: [:show_id]

      # GET /api/v1/residents/id
      def show_id
        render json: current_resident_api.id
      end

      # GET /api/v1/residents/name/:token
      def show_name
        resident = Resident.find_by(reset_password_token: params[:token])

        if resident.blank?
          render json: { message: 'Password reset link is incorrect or expired.' }, status: :bad_request and return
        end

        render json: { name: resident_name_helper(resident.name) }
      end

      # POST /api/v1/residents/token { email: 'email', password: 'password' }
      # Auth flow with multiple early-exit checks
      def token
        # Kids aren't required to have email addresses;
        # this prevents those accounts from signing in
        render json: { message: 'Email required.' }, status: :bad_request and return if params[:email].blank?

        resident = Resident.find_by(email: params[:email]&.strip&.downcase)
        if resident.blank?
          render json: { message: "No resident with email #{params[:email]}" }, status: :bad_request and return
        end

        if resident.authenticate(params[:password])
          render json: { token: resident.key.token, slug: resident.community.slug, community_id: resident.community.id,
                         resident_id: resident.id, username: resident_name_helper(resident.name) }
        else
          render json: { message: 'Incorrect password' }, status: :bad_request
        end
      end

      # --multi-step auth flow with email delivery
      # POST /api/v1/residents/password-reset { email: 'email' }
      def password_reset
        render json: { message: 'Email required.' }, status: :bad_request and return if params[:email].blank?

        resident = Resident.find_by(email: params[:email]&.strip&.downcase)

        if resident.blank?
          render json: { message: 'No resident with that email address.' }, status: :bad_request and return
        end

        resident.reset_password_token = SecureRandom.urlsafe_base64
        unless resident.save
          render json: { message: 'Error. Please try again.' }, status: :bad_request
          return
        end

        begin
          ResidentMailer.password_reset_email(resident).deliver_now
          render json: { message: 'Check your email.' }
        rescue *MAIL_DELIVERY_ERRORS => e
          Rails.logger.error("Password reset email failed for #{resident.email}: #{e.class} - #{e.message}")
          render json: {
                   message: 'Password reset saved but email could not be sent. Please contact an administrator.'
                 },
                 status: :service_unavailable
        end
      end

      # POST /api/v1/residents/password-reset/:token { password: 'password' }
      def password_new
        resident = Resident.find_by(reset_password_token: params[:token])

        render json: { message: 'Error.' }, status: :bad_request and return if resident.blank?

        resident.password = params[:password]

        render json: { message: 'Password updated!' } and return if resident.save

        render json: { message: 'Invalid password.' }, status: :bad_request
      end

      # GET api/v1/residents/:id/ical
      def ical # rubocop:disable Metrics/AbcSize, Metrics/MethodLength --iCal feed builds two event types from bills and meal_residents
        resident = Resident.find(params[:id])

        require 'icalendar/tzinfo'
        tzid = resident.community.timezone
        tz = TZInfo::Timezone.get tzid
        timezone = tz.ical_timezone DateTime.new 2017, 6, 1, 8, 0, 0

        cal = Icalendar::Calendar.new
        cal.add_timezone timezone

        cal.x_wr_calname = "My #{resident.community.name}"

        Bill.where(resident_id: resident.id).find_each do |bill|
          event = Icalendar::Event.new

          meal_date = bill.meal.date
          meal_date_time_start = DateTime.new(meal_date.year, meal_date.month, meal_date.day,
                                              meal_date.sunday? ? 18 : 19, 0)
          meal_date_time_end = DateTime.new(meal_date.year, meal_date.month, meal_date.day,
                                            meal_date.sunday? ? 20 : 21, 0)

          event.dtstart = Icalendar::Values::DateTime.new meal_date_time_start, 'tzid' => tzid
          event.dtend = Icalendar::Values::DateTime.new meal_date_time_end, 'tzid' => tzid
          event.summary = 'Cook Common Dinner'
          event.description = "#{bill.meal.description}\n\n\n\nView here: #{root_url}/meals/#{bill.meal.id}/edit"
          cal.add_event(event)
        end

        MealResident.where(resident_id: resident.id).find_each do |mr|
          event = Icalendar::Event.new

          meal_date = mr.meal.date
          meal_date_time_start = DateTime.new(meal_date.year, meal_date.month, meal_date.day,
                                              meal_date.sunday? ? 18 : 19, 0)
          meal_date_time_end = DateTime.new(meal_date.year, meal_date.month, meal_date.day,
                                            meal_date.sunday? ? 20 : 21, 0)

          event.dtstart = Icalendar::Values::DateTime.new meal_date_time_start, 'tzid' => tzid
          event.dtend = Icalendar::Values::DateTime.new meal_date_time_end, 'tzid' => tzid
          event.summary = 'Attend Common Dinner'
          event.description = "#{mr.meal.description}\n\n\n\nView here: #{root_url}/meals/#{mr.meal.id}/edit"
          if Bill.joins(:meal).where(resident_id: resident.id).where(meals: { date: mr.meal.date }).blank?
            cal.add_event(event)
          end
        end

        render plain: cal.to_ical, content_type: 'text/calendar'
      end

      private

      def authenticate
        not_authenticated_api unless signed_in_resident_api?
      end
    end
  end
end
