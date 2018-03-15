module Api
  module V1
    class CommonHouseReservationsController < ApplicationController
      def index
        if params[:start].present? && params[:end].present?
          grr = CommonHouseReservation.where(community_id: params[:community_id])
                        .where("start_date >= ?", params[:start])
                        .where("start_date <= ?", params[:end])

        else
          grr = CommonHouseReservation.where(community_id: params[:community_id]).all
        end

        render json: grr
      end

    end
  end
end
