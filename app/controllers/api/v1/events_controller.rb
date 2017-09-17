module Api
  module V1
    class EventsController < ApplicationController
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

    end
  end
end
