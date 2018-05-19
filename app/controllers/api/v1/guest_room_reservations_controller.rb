module Api
  module V1
    class GuestRoomReservationsController < ApplicationController

      # GET /api/v1/guest-room-reservations
      def index
        if params[:start].present? && params[:end].present?
          grrs = GuestRoomReservation.where(community_id: params[:community_id])
                        .where("date >= ?", params[:start])
                        .where("date <= ?", params[:end])

        else
          grrs = GuestRoomReservation.where(community_id: params[:community_id]).all
        end

        render json: grrs
      end

      # GET /api/v1/guest-room-reservations
      def show
        grr = GuestRoomReservation.find(params[:id])
        hosts = grr.community&.residents.adult.active.joins(:unit).order("units.name").pluck("residents.id", "residents.name", "units.name")
        render json: {event: grr, hosts: hosts}
      end

      # PATCH /api/v1/guest-room-reservations/:id/update
      def update
        grr = GuestRoomReservation.find(params[:id])

        if grr.update(date: params[:date], resident_id: params[:resident_id])
          render json: {message: 'Guest Room Reservation has been updated'}
        else
          render json: {message: grr.errors.full_messages.join("\n")}, status: :bad_request
        end
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
