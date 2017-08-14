class MealsController < ApplicationController
  before_action :set_meal

  # GET /meals/:id/edit (subdomains)
  def show
  end

  # GET /meals/:id/previous (subdomains)
  def previous
    meals = Meal.where(community_id: @meal.community_id).order(:date)
    meal_index = meals.find_index { |meal| meal.id == @meal.id }

    # Scenario #1: This is the first meal
    previous_index = meal_index if meal_index == 0

    # Scenario #2: This is NOT the first meal
    previous_index = meal_index - 1 if meal_index > 0

    @meal = meals[previous_index]
    redirect_to @meal
  end

  # GET /meals/:id/next (subdomains)
  def next
    meals = Meal.where(community_id: @meal.community_id).order(:date)
    meal_index = meals.find_index { |meal| meal.id == @meal.id }

    # Scenario #1: This is the last meal
    next_index = meal_index if meal_index == meals.size - 1

    # Scenario #2: This is NOT the last meal
    next_index = meal_index + 1 if meal_index < meals.size - 1

    @meal = meals[next_index]
    redirect_to @meal
  end

  # GET /meals/:id/log (subdomains)
  def log
  end

  private
  def set_meal
    @meal = Meal.find(params[:id])
  end
end
