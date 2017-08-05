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
        meal_resident = @meal.meal_residents.find_or_create_by(resident_id: params[:resident_id])
        if meal_resident.save
          render json: meal_resident
        else
          render json: { message: meal_resident.errors.first[1] }, status: :bad_request
        end
      end

      def destroy_resident
        if @meal_resident&.destroy
          render json: { message: 'MealResident destroyed.' } and return
        else
          render json: { message: 'Could not destroy MealResident.' }, status: :bad_request and return
        end
      end

      def update_resident
        if @meal_resident.update(meal_resident_params)
          render json: { message: 'MealResident updated.' } and return
        else
          render json: { message: 'Could not update MealResident.' }, status: :bad_request and return
        end
      end

      def create_guest
        guest = Guest.new(meal_id: @meal.id, resident_id: params[:resident_id])

        if guest.save
          render json: guest and return
        else
          render json: { message: guest.errors.first[1] }, status: :bad_request and return
        end
      end

      def destroy_guest
        if @meal.guests.find_by(resident_id: params[:resident_id])&.destroy
          render json: { message: 'Guest was destroyed.' } and return
        else
          render json: { message: 'Guest could not be destroyed.' }, status: :bad_request and return
        end
      end

      def show_cooks
        render json: CookFormSerializer.new(@meal), scope: @meal
      end

      def update_description
        if @meal.update(:description => params[:description])
          render json: { message: 'Description updated.' } and return
        else
          render json: { message: @meal.errors.first[1] }, status: :bad_request and return
        end
      end

      def update_max
        if @meal.update(:max => params[:max])
          render json: { message: 'Max updated.' } and return
        else
          render json: { message: @meal.errors.first[1] }, status: :bad_request and return
        end
      end

      def update_bills
        # Cooks
        cook_ids = []
        params[:bills].each do |bill|
          cook_ids.push(bill['resident_id'])
        end
        @meal.update(:cook_ids => cook_ids)
        @meal.reload

        # Bill Cost
        params[:bills].each do |bill|
          @meal.bills.find_by(resident_id: bill['resident_id']).update(amount_cents: bill['amount_cents'])
        end

        render json: { message: 'Form submitted.' }
      end

      def update_closed
        if @meal.update(closed: params[:closed])
          render json: { message: 'Meal closed value updated.' } and return
        else
          render json: { message: @meal.errors.first[1] }, status: :bad_request and return
        end
      end

      def update_max
        if @meal.update(max: params[:max])
          render json: { message: 'Meal max value updated.' } and return
        else
          render json: { message: @meal.errors.first[1] }, status: :bad_request and return
        end
      end

      private
      def meal_resident_params
        params.permit(:late, :vegetarian)
      end

      def set_meal
        @meal ||= Meal.find_by(id: params[:meal_id])
        @meal.socket_id = params[:socket_id]
      end

      def set_meal_resident
        @meal_resident ||= MealResident.find_by(meal_id: params[:meal_id], resident_id: params[:resident_id])
      end

    end
  end
end
