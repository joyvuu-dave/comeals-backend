module Api
  module V1
    class MealsController < ApplicationController
      before_action :authenticate
      before_action :authorize, only: [:index]
      before_action :authorize_one, except: [:index]
      before_action :set_meal, except: [:index]
      before_action :set_guest, only: [:destroy_guest]
      before_action :set_meal_resident, only: [:destroy_meal_resident, :update_meal_resident]
      after_action :trigger_pusher, except: [:index, :show, :show_cooks]

      # GET /api/v1/meals
      def index
        if params[:start].present? && params[:end].present?
          meals = Meal.where(community_id: params[:community_id]).where("date >= ?", params[:start]).where("date <= ?", params[:end])
        else
          meals = Meal.where(community_id: params[:community_id]).all
        end

        render json: meals
      end

      # GET /api/v1/meal/:meal_id
      def show
        render json: @meal
      end

      # POST /api/v1/meals/:meal_id/residents/:resident_id { late, vegetarian }
      def create_meal_resident
        meal_resident = @meal.meal_residents.find_or_create_by(resident_id: params[:resident_id], late: params[:late], vegetarian: params[:vegetarian])
        if meal_resident.save
          render json: meal_resident
        else
          render json: { message: meal_resident.errors.full_messages.join("\n") }, status: :bad_request
        end
      end

      # DELETE /api/v1/meals/:meal_id/residents/:resident_id
      def destroy_meal_resident
        @meal_resident.destroy!

        render json: { message: 'MealResident destroyed.' }
      end

      # PATCH /api/v1/meals/:meal_id/residents/:resident_id { late, vegetarian }
      def update_meal_resident
        if @meal_resident.update(meal_resident_params)
          render json: { message: 'MealResident updated.' } and return
        else
          render json: { message: @meal_resident.errors.full_messages.join("\n") }, status: :bad_request and return
        end
      end

      # POST /api/v1/meals/:meal_id/residents/:resident_id/guests { vegetarian }
      def create_guest
        guest = Guest.new(meal_id: @meal.id, resident_id: params[:resident_id], vegetarian: params[:vegetarian])

        if guest.save
          render json: guest and return
        else
          render json: { message: guest.errors.full_messages.join("\n") }, status: :bad_request and return
        end
      end

      # DELETE /api/v1/meals/:meal_id/residents/:resident_id/guests/:guest_id
      def destroy_guest
        @guest.destroy!

        render json: { message: 'Guest was destroyed.' }
      end

      # GET /api/v1/meals/:meal_id/cooks
      def show_cooks
        render json: @meal, serializer: MealFormSerializer
      end

      # PATCH /api/v1/meals/:meal_id/description { description }
      def update_description
        if @meal.update(:description => params[:description])
          render json: { message: 'Description updated.' } and return
        else
          render json: { message: @meal.errors.full_messages.join("\n") }, status: :bad_request and return
        end
      end

      # PATCH /api/v1/meals/:meal_id/max { max }
      def update_max
        if @meal.update(:max => params[:max])
          render json: { message: 'Meal max value updated.' } and return
        else
          render json: { message: @meal.errors.full_messages.join("\n") }, status: :bad_request and return
        end
      end

      # PATCH /meals/:meal_id/bills
      # PAYLOAD {id: 1, bills: [{resident_id: 3, amount_cents: 0}, {resident_id: "4", amount_cents: 0}]}
      def update_bills
        message = 'Form submitted.'
        request_symbol = :ok

        # Cooks
        cook_ids = []
        params[:bills].each do |bill|
          cook_ids.push(bill['resident_id'])
        end

        # Future meal
        if @meal.date > Date.today
          # More than two cooks
          if cook_ids.length > 2
            # Scenario #1: adding cooks
            if cook_ids.length > @meal.bills.count
              if @meal.another_meal_in_this_rotation_has_less_than_two_cooks?
                message = "Warning: third cooks should not be added until all meals in the rotation have at least two cooks."
                request_symbol = :bad_request
              end
            end

            # Scenario #2: switching cooks
            if cook_ids.length == @meal.bills.count
              if @meal.another_meal_in_this_rotation_has_less_than_two_cooks?
                message = "Warning: third cook should not be switched when there are other meals in the rotation without at least two cooks."
                request_symbol = :bad_request
              end
            end
          end
        end

        @meal.update(:cook_ids => cook_ids)
        @meal.reload

        # Bill Cost
        params[:bills].each do |bill|
          @meal.bills.find_by(resident_id: bill['resident_id']).update(amount_cents: bill['amount_cents'])
        end

        render json: { message: message }, status: request_symbol
      end

      # PATCH /api/v1/meals/:meal_id/closed { closed }
      def update_closed
        if @meal.update(closed: params[:closed])
          render json: { message: 'Meal closed value updated.' } and return
        else
          render json: { message: @meal.errors.full_messages.join("\n") }, status: :bad_request and return
        end
      end

      private
      def meal_resident_params
        params.permit(:late, :vegetarian)
      end

      def set_meal
        @meal ||= Meal.includes({ :residents => :unit }).find_by(id: params[:meal_id])

        not_found unless @meal.present?

        @meal.socket_id = params[:socket_id]
      end

      def set_guest
        @guest = @meal.guests.find_by(id: params[:guest_id])

        not_found unless @guest.present?
      end

      def set_meal_resident
        @meal_resident ||= MealResident.find_by(meal_id: params[:meal_id], resident_id: params[:resident_id])

        not_found unless @meal_resident.present?
      end

      def trigger_pusher
        @meal.trigger_pusher
      end

      def authenticate
        not_authenticated unless signed_in_resident?
      end

      def authorize
        not_authorized unless current_resident.community_id.to_s == params[:community_id]
      end

      def authorize_one
        not_authorized unless current_resident.community_id == @meal.community_id
      end

    end
  end
end
