class RotationsController < ApplicationController
  before_action :authenticate
  before_action :set_rotation
  before_action :authorize

  # GET /rotations/:id (subdomains)
  def show
    meal_ids = @rotation.meal_ids
    bill_ids = Bill.where(meal_id: meal_ids)

    # Signed Up Residents
    @signed_up_residents_ids = Bill.joins(:resident).where(id: bill_ids).pluck("residents.id")

    eligible_cooks_ids = @rotation.community.residents.where(can_cook: true, active: true).where("multiplier >= 2").ids
    @eligible_cooks = Resident.joins(:unit).where(id: eligible_cooks_ids).order("units.name")
  end

  private
  def authenticate
    not_authenticated unless signed_in_resident?
  end

  def set_rotation
    @rotation = Rotation.find_by(id: params[:id])
    not_found unless @rotation.present?
  end

  def authorize
    not_authorized unless current_resident.community == @rotation.community
  end
end
