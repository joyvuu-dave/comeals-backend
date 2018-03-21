module Api
  module V1
    class GuestRoomReservationsController < ApplicationController

      # GET /api/v1/guest-room-reservations
      def index
        if params[:start].present? && params[:end].present?
          grr = GuestRoomReservation.where(community_id: params[:community_id])
                        .where("date >= ?", params[:start])
                        .where("date <= ?", params[:end])

        else
          grr = GuestRoomReservation.where(community_id: params[:community_id]).all
        end

        render json: grr
      end

      # PATCH /api/v1/guest-room-reservations/:id/update
      def update
        grr = GuestRoomReservation.find(params[:id])
        grr.update!(date: params[:date], resident_id: params[:resident_id])

        render json: {message: 'Guest Room Reservation has been updated'}
      end

      # DELETE /api/v1/guest-room-reservations/:id/delete
      def destroy
        grr = GuestRoomReservation.find(params[:id])
        grr.destroy!

        render json: {message: 'Guest Room Reservation has been removed'}
      end

      # POST /api/v1/guest-room-reservations/create
      def create
        grr = GuestRoomReservation.new(resident_id: params[:resident_id], date: params[:date], community_id: params[:community_id])
        if grr.save
          render json: {message: 'Guest Room Reservation has been created'}
        else
          render json: {message: grr.errors.full_messages.join("\n")}, status: :bad_request
        end
      end
    end
  end
end
