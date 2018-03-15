module Api
  module V1
    class GuestRoomReservationsController < ApplicationController
      def index
        if params[:start].present? && params[:end].present?
          grr = GuestRoomReservation.where(community_id: params[:community_id])
                        .where("date >= ?", params[:start])
                        .where("date <= ?", params[:end])

        else
          grr = GuestRoomReservation.where(community_id: params[:community_id]).all
        end

        render json: grr
      end

    end
  end
end
