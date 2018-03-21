class GuestRoomReservationsController < ApplicationController
  before_action :set_hosts
  before_action :set_guest_room_reservation, only: [:edit]

  # GET /guest-room-reservations/:id/edit (subdomains)
  def edit
  end

  # get /guest-room-reservations/new (subdomains)
  def new
  end

  private
  def set_hosts
    community = Community.find_by(params[:community_id])
    @hosts = community&.residents.adult.active.joins(:unit).order("units.name").pluck("residents.id", "residents.name", "units.name")
  end

  def set_guest_room_reservation
    @event = GuestRoomReservation.find(params[:id])
  end
end
