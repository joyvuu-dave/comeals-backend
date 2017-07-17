class MealsController < ApplicationController
  def show
    @id = params[:id]
    render layout: 'current_resident'
  end
end
