module Api
  module V1
    class EventsController < ApplicationController

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
        event = Event.find(params[:id])
        residents = event.community&.residents.adult.active.joins(:unit).order("units.name").pluck("residents.id", "residents.name", "units.name")
        render json: {event: event, residents: residents}
      end

      # PATCH /api/v1/events/:id/update
      def update
        event = Event.find(params[:id])

        if params.has_key?(:all_day)
          allday = params[:all_day].to_s == "true" ? true : false
        else
          allday = event.allday
        end

        if allday
          start_date = DateTime.new(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i, 0, 0)
          end_date = nil
        else
          start_date = DateTime.new(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i, params[:start_hours].to_i, params[:start_minutes].to_i)
          end_date = DateTime.new(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i, params[:end_hours].to_i, params[:end_minutes].to_i)
        end

        if event.update(start_date: start_date, end_date: end_date, allday: allday, description: params[:description], title: params[:title])
          render json: {message: 'Event has been updated'}
        else
          render json: {message: event.errors.full_messages.join("\n")}, status: :bad_request
        end
      end

      # DELETE /api/v1/events/:id/delete
      def destroy
        event = Event.find(params[:id])
        event.destroy!

        render json: {message: 'Event has been removed'}
      end

      # POST /api/v1/events/create
      def create
        if params.has_key?(:all_day)
          allday = params[:all_day].to_s == "true" ? true : false
        else
          allday = false
        end

        if allday
          start_date = DateTime.new(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i, 0, 0)
          end_date = nil
        else
          start_date = DateTime.new(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i, params[:start_hours].to_i, params[:start_minutes].to_i)
          end_date = DateTime.new(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i, params[:end_hours].to_i, params[:end_minutes].to_i)
        end

        event = Event.new(start_date: start_date, end_date: end_date, title: params[:title], description: params[:description], community_id: params[:community_id], allday: allday)
        if event.save
          render json: {message: 'Event has been created'}
        else
          render json: {message: event.errors.full_messages.join("\n")}, status: :bad_request
        end
      end

    end
  end
end
