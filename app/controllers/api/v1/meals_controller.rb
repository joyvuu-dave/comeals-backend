module Api
  module V1
    class MealsController < ApplicationController
      before_action :set_meal, except: [:index]
      before_action :set_meal_resident, only: [:destroy_resident, :update_resident]

      def index
        if params[:start].present? && params[:end].present?
          meals = Meal.where("date >= ?", params[:start]).where("date <= ?", params[:end])
        else
          meals = Meal.all
        end

        render json: meals
      end

      def show
        render json: @meal
      end

      def show_attendees
        render json: @meal.community.residents, each_serializer: AttendeeSerializer, scope: @meal
      end

      def create_resident
        meal_resident = @meal.meal_residents.find_or_create_by!(resident_id: params[:resident_id])
        render json: meal_resident
      end

      def destroy_resident
        if @meal_resident&.destroy
          render json: { message: 'MealResident destroyed.' } and return
        else
          render json: { message: 'Could not destroy MealResident.' }, status: :bad_request and return
        end
      end

      def update_resident
        if @meal_resident.update_attributes(meal_params)
          render json: { message: 'MealResident updated.' } and return
        else
          render json: { message: 'Could not update MealResident.' }, status: :bad_request and return
        end
      end

      def create_guest
        guest = @meal.guests.find_or_create_by!(resident_id: params[:resident_id])
        render json: guest
      end

      def destroy_guest
        if @meal.guests.find_by(resident_id: params[:resident_id])&.destroy
          render json: { message: 'Guest was destroyed.' } and return
        else
          render json: { message: 'Guest could not be destroyed.' }, status: :bad_request and return
        end
      end

      def show_cooks
        render json: CookFormSerializer.new(@meal)
      end

      def update_meal_and_bills
        # @meal.update_attributes(description: params[:description], max: params[:max], closed: params[:closed]) 
        # @meal.cook_ids = params[:bills].map { |bill| bill[:resident_id] } 
        # params[:bills].each do |bill| 
        #   @meal.bills.find_by(resident_id: bill[:resident_id]).update_attributes(amount_cents: bill[:cost]) 
        # end

        render json: { message: 'Request processsed.' }
      end

      private
      def meal_params
        params.permit(:late, :vegetarian)
      end

      def set_meal
        @meal ||= Meal.find_by(id: params[:meal_id])
      end

      def set_meal_resident
        @meal_resident ||= MealResident.find_by(meal_id: params[:meal_id], resident_id: params[:resident_id])
      end

    end
  end
end
