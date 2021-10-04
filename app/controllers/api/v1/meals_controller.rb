module Api
  module V1
    class MealsController < ApiController
      before_action :authenticate
      before_action :authorize, only: [:index]
      before_action :set_meal, except: [:index, :next]
      before_action :authorize_one, except: [:index, :next]
      before_action :set_guest, only: [:destroy_guest]
      before_action :set_meal_resident, only: [:destroy_meal_resident, :update_meal_resident]
      after_action :trigger_pusher, except: [:index, :next, :show, :history, :show_cooks]

      # GET /api/v1/meals
      def index
        if params[:start].present? && params[:end].present?
          meals = Meal.where(community_id: params[:community_id]).where("date >= ?", params[:start]).where("date <= ?", params[:end])
        else
          meals = Meal.where(community_id: params[:community_id]).all
        end

        render json: meals
      end

      # GET /api/v1/meals/next
      def next
        next_meal = Meal.where("date >= ?", Time.now.to_date).first

        if next_meal.nil?
          render json: { meal_id: nil }, status: :bad_request
        else
          render json: { meal_id: next_meal.id }
        end
      end

      # GET /api/v1/meals/:meal_id
      def show
        render json: @meal
      end

      # GET /api/v1/meals/:meal_id/history
      def history
        render json: {
          date: @meal.date,
          items: ActiveModelSerializers::SerializableResource.new(@meal.total_audits, each_serializer: AuditSerializer).as_json
        }
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
        key = "meal-#{params[:meal_id]}"

        cached_value = Rails.cache.read(key)

        if cached_value.nil?
          result = ActiveModelSerializers::SerializableResource.new(@meal, serializer: MealFormSerializer, scope: @meal).as_json
          Rails.cache.write(key, result)
        else
          result = cached_value
        end

        render json: result
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
      # PAYLOAD {id: 1, bills: [{resident_id: 3, amount_cents: 0, no_cost: true}, {resident_id: "4", amount_cents: 0, no_cost: true}]}
      def update_bills
        # FIXME: temp hack
        if @meal.reconciliation_id.present? && @meal.reconciliation_id <= 3 then
          render json: { message: 'Cost change not permitted. Meal has already been reconciled.' }, status: :bad_request and return
        end

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
          @meal.bills.find_by(resident_id: bill['resident_id']).update({amount_cents: bill['amount_cents'], no_cost: bill['no_cost']})
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

        not_found_api unless @meal.present?

        @meal.socket_id = params[:socket_id]
      end

      def set_guest
        @guest = @meal.guests.find_by(id: params[:guest_id])

        not_found_api unless @guest.present?
      end

      def set_meal_resident
        @meal_resident ||= MealResident.find_by(meal_id: params[:meal_id], resident_id: params[:resident_id])

        not_found_api unless @meal_resident.present?
      end

      def trigger_pusher
        @meal.trigger_pusher
      end

      def authenticate
        not_authenticated_api unless signed_in_resident_api?
      end

      def authorize
        not_authorized_api unless current_resident_api.community_id.to_s == params[:community_id]
      end

      def authorize_one
        not_authorized_api unless current_resident_api.community_id == @meal.community_id
      end

    end
  end
end
