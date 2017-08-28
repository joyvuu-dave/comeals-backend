class RotationsController < ApplicationController
  # GET /rotations/:id (subdomains)
  def show
    @rotation = Rotation.find(params[:id])
    meal_ids = @rotation.meal_ids
    bill_ids = Bill.where(meal_id: meal_ids)

    # Signed Up Residents
    signed_up_residents_ids = Bill.joins(:resident).where(id: bill_ids).pluck("residents.id")
    @signed_up_residents = Resident.joins(:unit).where(id: signed_up_residents_ids).order("units.name")

    community = @rotation.community
    elible_cooks_ids = community.residents.where("multiplier >= 2").where(can_cook: true).ids

    # Residents eligble to cook who aren't signed up
    un_signed_up_resident_ids = elible_cooks_ids - signed_up_residents_ids
    @un_signed_up_residents = Resident.joins(:unit).where(id: un_signed_up_resident_ids).order("units.name")
  end

end
