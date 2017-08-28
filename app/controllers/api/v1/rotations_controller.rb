module Api
  module V1
    class RotationsController < ApplicationController
      def index
        if params[:start].present? && params[:end].present?
          #rotations = Meal.includes(:rotation).where.not(rotation_id: nil).where("date >= ?", params[:start]).where("date <= ?", params[:end]).rotations
          rotations = Rotation.all
        else
          rotations = Rotation.all
        end

        render json: rotations
      end

    end
  end
end
