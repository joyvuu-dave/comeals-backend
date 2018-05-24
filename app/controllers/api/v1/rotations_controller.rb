module Api
  module V1
    class RotationsController < ApplicationController
      before_action :authenticate
      before_action :authorize

      def index
        if params[:start].present? && params[:end].present?
          rotation_ids = Meal.where(community_id: params[:community_id])
                             .where("date >= ?", params[:start])
                             .where("date <= ?", params[:end])
                             .where.not(rotation_id: nil)
                             .pluck(:rotation_id).uniq
          rotations = Rotation.find(rotation_ids)
        else
          rotations = Rotation.where(community_id: params[:community_id])
        end

        render json: rotations
      end

      private
      def authenticate
        not_authenticated unless signed_in_resident?
      end

      def authorize
        not_authorized unless current_resident.community_id.to_s == params[:community_id]
      end
    end
  end
end
