class RotationsController < ApplicationController
  # GET /rotations/:id (subdomains)
  def show
    @rotation = Rotation.find(params[:id])
  end

end
