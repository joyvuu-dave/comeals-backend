# frozen_string_literal: true

module Api
  module V1
    class MealsController < ApiController
      before_action :authenticate
      before_action :authorize, only: [:index]
      before_action :set_meal, except: %i[index next]
      before_action :authorize_one, except: %i[index next]
      before_action :set_guest, only: [:destroy_guest]
      before_action :set_meal_resident, only: %i[destroy_meal_resident update_meal_resident]
      after_action :trigger_pusher, except: %i[index next show history show_cooks]

      # GET /api/v1/meals
      def index
        meals = if params[:start].present? && params[:end].present?
                  Meal.where(community_id: params[:community_id])
                      .where(date: (params[:start])..)
                      .where(date: ..(params[:end]))
                else
                  Meal.where(community_id: params[:community_id]).all
                end

        render json: meals
      end

      # GET /api/v1/meals/next
      def next
        next_meal = Meal.where(community_id: current_resident_api.community_id)
                        .where(date: Time.zone.now.to_date..)
                        .order(:date).first

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
          items: ActiveModelSerializers::SerializableResource.new(@meal.total_audits,
                                                                  each_serializer: AuditSerializer).as_json
        }
      end

      # POST /api/v1/meals/:meal_id/residents/:resident_id { late, vegetarian }
      # Uses pessimistic locking (SELECT ... FOR UPDATE) to prevent concurrent
      # signups from exceeding meal.max. The lock serializes writes to the same
      # meal row; other meals are unaffected.
      #
      # Uses find_or_initialize_by(resident_id:) rather than the previous
      # find_or_create_by(resident_id:, late:, vegetarian:). This means
      # re-signing up with different late/vegetarian values updates the
      # existing signup instead of erroring on the unique index.
      def create_meal_resident
        @meal.with_lock do
          meal_resident = @meal.meal_residents.find_or_initialize_by(resident_id: params[:resident_id])
          meal_resident.assign_attributes(late: params[:late], vegetarian: params[:vegetarian])
          if meal_resident.save
            render json: meal_resident
          else
            render json: { message: meal_resident.errors.full_messages.join("\n") }, status: :bad_request
          end
        end
      end

      # DELETE /api/v1/meals/:meal_id/residents/:resident_id
      def destroy_meal_resident
        @meal_resident.destroy!

        render json: { message: 'MealResident destroyed.' }
      end

      # PATCH /api/v1/meals/:meal_id/residents/:resident_id { late, vegetarian }
      def update_meal_resident
        render json: { message: 'MealResident updated.' } and return if @meal_resident.update(meal_resident_params)

        render json: { message: @meal_resident.errors.full_messages.join("\n") }, status: :bad_request
      end

      # POST /api/v1/meals/:meal_id/residents/:resident_id/guests { vegetarian }
      # Uses pessimistic locking to prevent concurrent guest additions from
      # exceeding meal.max.
      def create_guest
        @meal.with_lock do
          guest = Guest.new(meal_id: @meal.id, resident_id: params[:resident_id], vegetarian: params[:vegetarian])
          if guest.save
            render json: guest
          else
            render json: { message: guest.errors.full_messages.join("\n") }, status: :bad_request
          end
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
          result = ActiveModelSerializers::SerializableResource.new(@meal, serializer: MealFormSerializer,
                                                                           scope: @meal).as_json
          Rails.cache.write(key, result)
        else
          result = cached_value
        end

        render json: result
      end

      # PATCH /api/v1/meals/:meal_id/description { description }
      def update_description
        render json: { message: 'Description updated.' } and return if @meal.update(description: params[:description])

        render json: { message: @meal.errors.full_messages.join("\n") }, status: :bad_request
      end

      # PATCH /api/v1/meals/:meal_id/max { max }
      def update_max
        render json: { message: 'Meal max value updated.' } and return if @meal.update(max: params[:max])

        render json: { message: @meal.errors.full_messages.join("\n") }, status: :bad_request
      end

      # PATCH /meals/:meal_id/bills
      # PAYLOAD {id: 1, bills: [{resident_id: 3, amount: "0.00",
      #   no_cost: true}, {resident_id: "4", amount: "0.00",
      #   no_cost: true}]}
      def update_bills # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength --multi-step bill validation + cook-scheduling guards
        if @meal.reconciliation_id.present?
          render json: { message: 'Cost change not permitted. Meal has already been reconciled.' },
                 status: :bad_request and return
        end

        message = 'Form submitted.'
        request_symbol = :ok
        message_type = nil

        # Cooks
        cook_ids = params[:bills].pluck('resident_id')

        # Future meal
        # More than two cooks
        if (@meal.date > Time.zone.today) && (cook_ids.length > 2)
          existing_cook_ids = @meal.bills.pluck(:resident_id).map(&:to_s).sort
          new_cook_ids = cook_ids.map(&:to_s).sort
          cooks_changed = new_cook_ids != existing_cook_ids

          # Scenario #1: adding cooks
          if (cook_ids.length > existing_cook_ids.length) && @meal.another_meal_in_this_rotation_has_less_than_two_cooks?
            message = 'Warning: third cooks should not be added until all meals ' \
                      'in the rotation have at least two cooks.'
            request_symbol = :bad_request
            message_type = 'warning'
          end

          # Scenario #2: switching cooks
          if (cook_ids.length == existing_cook_ids.length) && cooks_changed && @meal.another_meal_in_this_rotation_has_less_than_two_cooks?
            message = 'Warning: third cook should not be switched when there are ' \
                      'other meals in the rotation without at least two cooks.'
            request_symbol = :bad_request
            message_type = 'warning'
          end
        end

        @meal.update(cook_ids: cook_ids)
        @meal.reload

        # Bill Cost --validate all amounts before persisting any changes
        parsed_bills = []
        params[:bills].each do |bill|
          amount_str = bill['amount'].to_s
          amount_str = '0' if amount_str.blank?
          begin
            amount_value = BigDecimal(amount_str)
          rescue ArgumentError
            render json: { message: "Invalid amount: #{bill['amount']}" }, status: :bad_request
            return # rubocop:disable Lint/NonLocalExitFromIterator -- intentional: render error and exit action
          end
          parsed_bills << { resident_id: bill['resident_id'], amount: amount_value, no_cost: bill['no_cost'] }
        end

        parsed_bills.each do |bill|
          @meal.bills.find_by(resident_id: bill[:resident_id]).update(amount: bill[:amount], no_cost: bill[:no_cost])
        end

        payload = { message: message }
        payload[:type] = message_type if message_type
        render json: payload, status: request_symbol
      end

      # PATCH /api/v1/meals/:meal_id/closed { closed }
      def update_closed
        render json: { message: 'Meal closed value updated.' } and return if @meal.update(closed: params[:closed])

        render json: { message: @meal.errors.full_messages.join("\n") }, status: :bad_request
      end

      private

      def meal_resident_params
        params.permit(:late, :vegetarian)
      end

      def set_meal
        @meal = Meal.includes(:bills, :meal_residents, :guests).find_by(id: params[:meal_id]) unless defined?(@meal)

        return not_found_api if @meal.blank?

        @meal.socket_id = params[:socket_id]
      end

      def set_guest
        @guest = @meal.guests.find_by(id: params[:guest_id])

        not_found_api if @guest.blank?
      end

      def set_meal_resident
        unless defined?(@meal_resident)
          @meal_resident = MealResident.find_by(meal_id: params[:meal_id], resident_id: params[:resident_id])
        end

        not_found_api if @meal_resident.blank?
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
