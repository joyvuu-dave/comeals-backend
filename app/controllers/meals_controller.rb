class MealsController < ApplicationController
  before_action :set_meal
  before_action :authenticate
  before_action :authorize

  # GET /meals/:id/edit (subdomains)
  def edit
    @version = version
  end

  private
  def set_meal
    @meal = Meal.find_by(id: params[:id])
    not_found unless @meal.present?
  end

  def authenticate
    not_authenticated unless signed_in_resident?
  end

  def authorize
    not_authorized unless current_resident.community == @meal.community
  end
end
