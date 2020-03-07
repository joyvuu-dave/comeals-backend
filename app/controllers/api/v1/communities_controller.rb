module Api
  module V1
    class CommunitiesController < ApiController
      before_action :authenticate, except: [:ical]
      before_action :authorize, except: [:ical]
      before_action :set_community, only: [:birthdays, :calendar]

      # GET /api/v1/communities/:id/ical
      def ical
        community = Community.find(params[:id])

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
          event.description = "#{meal.description}\n\n\n\nSign up here: #{root_url}/meals/#{meal.id}/edit"
          cal.add_event(event)
        end

        render plain: cal.to_ical, content_type: "text/calendar"
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

      # GET /api/v1/communities/:id/calendar/:date
      def calendar
        date = Date.parse(params[:date])

        start_date = date.beginning_of_month.beginning_of_week(:sunday)
        end_date = start_date + 41.days
        month_int_array = (start_date.month..end_date.month).to_a

        month = (start_date + 20.days).month
        year = (start_date + 20.days).year

        start_date = start_date.to_s
        end_date = end_date.to_s

        key = "community-#{@community.id}-calendar-#{year}-#{month}"
        cached_value = Rails.cache.read(key)

        if cached_value.nil?
          result = ActiveModelSerializers::SerializableResource.new(@community, month: month, year: year, start_date: start_date, end_date: end_date, month_int_array: month_int_array, serializer: CalendarSerializer).as_json
          # FIXME: cache not getting properly deleted
          #Rails.cache.write(key, result)
        else
          result = cached_value
        end

        render json: result
      end

      private
      def set_community
        @community = Community.find_by(id: params[:id])
        not_found_api unless @community.present?
      end

      private
      def authenticate
        not_authenticated_api unless signed_in_resident_api?
      end

      def authorize
        not_authorized_api unless current_resident_api.community_id.to_s == params[:id]
      end

    end
  end
end
