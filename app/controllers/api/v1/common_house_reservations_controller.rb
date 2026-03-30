# frozen_string_literal: true

module Api
  module V1
    class CommonHouseReservationsController < ApiController
      before_action :authenticate
      before_action :set_resource, only: %i[show update destroy]
      before_action :authorize, only: %i[index create]
      before_action :authorize_one, only: %i[show update destroy]

      # GET /api/v1/common-house-reservations?start_date=123
      def index
        chrs = if params[:start].present? && params[:end].present?
                 CommonHouseReservation.includes({ resident: :unit }).where(community_id: params[:community_id])
                                       .where(start_date: (params[:start])..)
                                       .where(start_date: ..(params[:end]))

               else
                 CommonHouseReservation.includes({ resident: :unit }).where(community_id: params[:community_id]).all
               end

        render json: chrs
      end

      # GET /api/v1/common-house-reservations/:id
      def show
        residents = @chr.community.residents.adult.active
                        .joins(:unit).order('units.name')
                        .pluck('residents.id', 'residents.name', 'units.name')

        render json: { event: @chr, residents: residents }
      end

      # POST /api/v1/common-house-reservations
      # { resident_id, start_year, start_month, start_day,
      #   start_hours, start_minutes, end_hours, end_minutes, title }
      def create # rubocop:disable Metrics/AbcSize --date params require many attribute reads
        begin
          start_date = Time.zone.local(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i,
                                       params[:start_hours].to_i, params[:start_minutes].to_i)
          end_date = Time.zone.local(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i,
                                     params[:end_hours].to_i, params[:end_minutes].to_i)
        rescue StandardError
          render json: { message: 'Error: Invalid date' }, status: :bad_request and return
        end

        chr = CommonHouseReservation.new(resident_id: params[:resident_id], start_date: start_date, end_date: end_date,
                                         community_id: params[:community_id], title: params[:title])
        if chr.save
          render json: { message: 'Common House Reservation has been created' }
        else
          render json: { message: chr.errors.full_messages.join("\n") }, status: :bad_request
        end
      end

      # PATCH /api/v1/common-house-reservations/:id/update
      def update
        start_date = Time.zone.local(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i,
                                     params[:start_hours].to_i, params[:start_minutes].to_i)
        end_date = Time.zone.local(params[:start_year].to_i, params[:start_month].to_i, params[:start_day].to_i,
                                   params[:end_hours].to_i, params[:end_minutes].to_i)

        if @chr.update(start_date: start_date, end_date: end_date, resident_id: params[:resident_id],
                       title: params[:title])
          render json: { message: 'Common House Reservation has been updated' }
        else
          render json: { message: @chr.errors.full_messages.join("\n") }, status: :bad_request
        end
      end

      # DELETE /api/v1/common-house-reservations/:id/delete
      def destroy
        @chr.destroy!

        render json: { message: 'Common House Reservation has been removed' }
      end

      private

      def authenticate
        not_authenticated_api unless signed_in_resident_api?
      end

      def set_resource
        @chr = CommonHouseReservation.find_by(id: params[:id])

        not_found_api if @chr.blank?
      end

      def authorize
        not_authorized_api unless current_resident_api.community_id.to_s == params[:community_id]
      end

      def authorize_one
        not_authorized_api unless current_resident_api.community_id == @chr.community_id
      end
    end
  end
end
