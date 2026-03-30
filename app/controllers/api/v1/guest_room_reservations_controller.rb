# frozen_string_literal: true

module Api
  module V1
    class GuestRoomReservationsController < ApiController
      before_action :authenticate
      before_action :set_resource, only: %i[show update destroy]
      before_action :authorize, only: %i[index create]
      before_action :authorize_one, only: %i[show update destroy]

      # GET /api/v1/guest-room-reservations
      def index
        grrs = if params[:start].present? && params[:end].present?
                 GuestRoomReservation.includes({ resident: :unit }).where(community_id: params[:community_id])
                                     .where(date: (params[:start])..)
                                     .where(date: ..(params[:end]))

               else
                 GuestRoomReservation.includes({ resident: :unit }).where(community_id: params[:community_id]).all
               end

        render json: grrs
      end

      # GET /api/v1/guest-room-reservations
      def show
        active_residents = @grr.community.residents.adult.active
        hosts = active_residents.joins(:unit).order('units.name')
                                .pluck('residents.id', 'residents.name', 'units.name')
        render json: { event: @grr, hosts: hosts }
      end

      # POST /api/v1/guest-room-reservations/create
      def create
        grr = GuestRoomReservation.new(resident_id: params[:resident_id], date: params[:date],
                                       community_id: params[:community_id])
        if grr.save
          render json: { message: 'Guest Room Reservation has been created' }
        else
          render json: { message: grr.errors.full_messages.join("\n") }, status: :bad_request
        end
      end

      # PATCH /api/v1/guest-room-reservations/:id/update
      def update
        if @grr.update(date: params[:date], resident_id: params[:resident_id])
          render json: { message: 'Guest Room Reservation has been updated' }
        else
          render json: { message: @grr.errors.full_messages.join("\n") }, status: :bad_request
        end
      end

      # DELETE /api/v1/guest-room-reservations/:id/delete
      def destroy
        @grr.destroy!

        render json: { message: 'Guest Room Reservation has been removed' }
      end

      private

      def authenticate
        not_authenticated_api unless signed_in_resident_api?
      end

      def set_resource
        @grr = GuestRoomReservation.find_by(id: params[:id])

        not_found_api if @grr.blank?
      end

      def authorize
        not_authorized_api unless current_resident_api.community_id.to_s == params[:community_id]
      end

      def authorize_one
        not_authorized_api unless current_resident_api.community_id == @grr.community_id
      end
    end
  end
end
