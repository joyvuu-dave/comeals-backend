class CommonHouseReservationsController < ApplicationController
  before_action :set_residents
  before_action :set_common_house_reservation, only: [:edit]

  # GET /common-house-reservations/:id/edit (subdomains)
  def edit
  end

  # get /common-house-reservation/new (subdomains)
  def new
  end

  private
  def set_residents
    community = Community.find_by(params[:community_id])
    @residents = community&.residents.adult.active.joins(:unit).order("units.name").pluck("residents.id", "residents.name", "units.name")
  end

  def set_common_house_reservation
    @event = CommonHouseReservation.find(params[:id])
  end
end
