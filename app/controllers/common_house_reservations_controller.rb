class CommonHouseReservationsController < ApplicationController
  before_action :set_common_house_reservation

  # GET /common-house-reservations/:id/edit (subdomains)
  def edit
  end

  private
  def set_common_house_reservation
    @event = CommonHouseReservation.find(params[:id])
  end
end
