module Api
  module V1
    class EventsController < ApiController
      before_action :authenticate
      before_action :set_resource, only: [:show, :update, :destroy]
      before_action :authorize, only: [:index, :create]
      before_action :authorize_one, only: [:show, :update, :destroy]

      # GET /api/v1/events
      def index
        if params[:start].present? && params[:end].present?
          events = Event.where(community_id: params[:community_id])
                        .where("start_date >= ?", params[:start])
                        .where("start_date <= ?", params[:end])
                        .or(Event.where(community_id: params[:community_id])
                                 .where("end_date >= ?", params[:start])
                                 .where("end_date <= ?", params[:end]))
                        .or(Event.where(community_id: params[:community_id])
                                 .where("start_date < ?", params[:start])
                                 .where("end_date > ?", params[:end]))
        else
          events = Event.where(community_id: params[:community_id]).all
        end

        render json: events
      end

      # GET /api/v1/events/:id
      def show
        render json: @event, adapter: nil
      end

      # PATCH /api/v1/events/:id/update
      def update
        if params.has_key?(:all_day)
          allday = params[:all_day].to_s == "true" ? true : false
        else
          allday = @event.allday
        end

        if allday
          start_date = Time.zone.local(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i, 0, 0)
          end_date = nil
        else
          start_date = Time.zone.local(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i, params[:start_hours].to_i, params[:start_minutes].to_i)
          end_date = Time.zone.local(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i, params[:end_hours].to_i, params[:end_minutes].to_i)
        end

        if @event.update(start_date: start_date, end_date: end_date, allday: allday, description: params[:description], title: params[:title])
          render json: {message: 'Event has been updated'}
        else
          render json: {message: @event.errors.full_messages.join("\n")}, status: :bad_request
        end
      end

      # DELETE /api/v1/events/:id/delete
      def destroy
        @event.destroy!

        render json: {message: 'Event has been removed'}
      end

      # POST /api/v1/events/create
      def create
        if params.has_key?(:all_day)
          allday = params[:all_day].to_s == "true" ? true : false
        else
          allday = false
        end

        begin
          if allday
            start_date = Time.zone.local(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i, 0, 0)
            end_date = nil
          else
            start_date = Time.zone.local(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i, params[:start_hours].to_i, params[:start_minutes].to_i)
            end_date = Time.zone.local(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i, params[:end_hours].to_i, params[:end_minutes].to_i)
          end
        rescue
          render json: {message: 'Error: Invalid date'}, status: :bad_request and return
        end

        event = Event.new(start_date: start_date, end_date: end_date, title: params[:title], description: params[:description], community_id: params[:community_id], allday: allday)
        if event.save
          render json: {message: 'Event has been created'}
        else
          render json: {message: event.errors.full_messages.join("\n")}, status: :bad_request
        end
      end

      private
      def authenticate
        not_authenticated_api unless signed_in_resident_api?
      end

      def set_resource
        @event = Event.find_by(id: params[:id])

        not_found_api unless @event.present?
      end

      def authorize
        not_authorized_api unless current_resident_api.community_id.to_s == params[:community_id]
      end

      def authorize_one
        not_authorized_api unless current_resident_api.community_id == @event.community_id
      end

    end
  end
end
