module Api
  module V1
    class CommunitiesController < ApplicationController
      before_action :authenticate, except: [:create, :ical]
      before_action :authorize, except: [:create, :ical]
      before_action :set_community, only: [:birthdays, :database]

      # GET /api/v1/communities/:id/database
      def database
        meals = Meal.includes({ :residents => :unit,
                                :community => :bills,
                                :community => { :meals => :residents },
                                :community => :meal_residents,
                                :community => { :residents => :unit } })
                    .unreconciled
                    .where(community_id: @community.id)

        render json: meals, each_serializer: MealFormSerializer
      end

      # POST /api/v1/communities
      def create
        community = Community.new(name: params[:name], admin_users_attributes: [{ email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation]}])
        if community.save
          render json: { message: "#{community.name} has been created." } and return
        else
          render json: { message: community.errors.full_messages.join("\n") }, status: :bad_request and return
        end
      end

      # GET /api/v1/communities/:id/ical
      def ical
        community = Community.find(params[:id])

        respond_to do |format|
          format.ics do

            require 'icalendar/tzinfo'
            tzid = community.timezone
            tz = TZInfo::Timezone.get tzid
            timezone = tz.ical_timezone DateTime.new 2017, 6, 1, 8, 0, 0

            cal = Icalendar::Calendar.new
            cal.add_timezone timezone

            cal.x_wr_calname = community.name

            Meal.where(community_id: community.id).each do |meal|
              event = Icalendar::Event.new

              meal_date = meal.date
              meal_date_time_start = DateTime.new(meal_date.year, meal_date.month, meal_date.day, meal_date.sunday? ? 18 : 19, 0)
              meal_date_time_end = DateTime.new(meal_date.year, meal_date.month, meal_date.day, meal_date.sunday? ? 20 : 21, 0)

              event.dtstart = Icalendar::Values::DateTime.new meal_date_time_start, 'tzid' => tzid
              event.dtend = Icalendar::Values::DateTime.new meal_date_time_end, 'tzid' => tzid
              event.summary = "Common Dinner"
              event.description = "#{meal.description}\n\n\n\nSign up here: #{host}#{community.slug}.comeals#{top_level}/meals/#{meal.id}/edit"
              cal.add_event(event)
            end

            render plain: cal.to_ical, content_type: "text/calendar"
          end
        end
      end

      # GET /api/v1/communities/:id/birthdays
      def birthdays
        if params[:start]
          month_int = (Date.parse(params[:start]) + 2.weeks).month
        else
          month_int = Date.today.month
        end

        render json: @community.residents.active.where('extract(month from birthday) = ?', month_int), each_serializer: ResidentBirthdaySerializer
      end

      # GET /api/v1/communities/:id/hosts
      def hosts
        hosts = Resident.adult.active.where(community_id: params[:id]).joins(:unit).order("units.name").pluck("residents.id", "residents.name", "units.name")
        render json: hosts
      end

      private
      def set_community
        @community = Community.find_by(id: params[:id])
        not_found_api unless @community.present?
      end

      private
      def authenticate
        not_authenticated_api unless signed_in_resident?
      end

      def authorize
        not_authorized_api unless current_resident.community_id.to_s == params[:id]
      end

    end
  end
end
