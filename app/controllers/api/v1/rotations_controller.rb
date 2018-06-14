module Api
  module V1
    class RotationsController < ApiController
      before_action :authenticate
      before_action :set_resource, only: [:show]
      before_action :authorize, only: [:index]
      before_action :authorize_one, only: [:show]

      # GET /api/v1/rotations
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

      # GET /api/v1/rotations/:id
      def show
        render json: @rotation, cook_ids: @rotation.cook_ids, serializer: RotationLogSerializer
      end

      private
      def authenticate
        not_authenticated_api unless signed_in_resident_api?
      end

      def set_resource
        @rotation = Rotation.includes({:residents => :unit}).find_by(id: params[:id])

        not_found_api unless @rotation.present?
      end

      def authorize
        not_authorized_api unless current_resident_api.community_id.to_s == params[:community_id]
      end

      def authorize_one
        not_authorized_api unless current_resident_api.community_id == @rotation.community_id
      end
    end
  end
end
