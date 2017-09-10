class RotationsController < ApplicationController
  # GET /rotations/:id (subdomains)
  def show
    @rotation = Rotation.find(params[:id])
    meal_ids = @rotation.meal_ids
    bill_ids = Bill.where(meal_id: meal_ids)

    # Signed Up Residents
    @signed_up_residents_ids = Bill.joins(:resident).where(id: bill_ids).pluck("residents.id")

    community = @rotation.community

    eligible_cooks_ids = community.residents.where("multiplier >= 2").ids
    @eligible_cooks = Resident.joins(:unit).where(id: eligible_cooks_ids).order("units.name")
  end

end
