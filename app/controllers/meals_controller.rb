class MealsController < ApplicationController
  def show
    @meal = Meal.find(params[:id])
    render layout: 'current_resident'
  end
end
