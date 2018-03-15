class GuestRoomReservationsController < ApplicationController
  before_action :set_guest_room_reservation

  # GET /guest-room-reservations/:id/edit (subdomains)
  def edit
    community = Community.find_by(params[:community_id])
    @hosts = community&.residents.adult.active.joins(:unit).order("units.name").pluck("residents.id", "residents.name", "units.name")
  end

  private
  def set_guest_room_reservation
    @event = GuestRoomReservation.find(params[:id])
  end
end
