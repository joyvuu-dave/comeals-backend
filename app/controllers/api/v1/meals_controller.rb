module Api
  module V1
    class MealsController < ApplicationController
      def index
        if params[:start].present? && params[:end].present?
          meals = Meal.where("date >= ?", params[:start]).where("date <= ?", params[:end])
        else
          meals = Meal.all
        end

        render json: meals
      end

    end
  end
end
