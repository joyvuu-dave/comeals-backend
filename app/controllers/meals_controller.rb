class MealsController < ApplicationController
  before_action :set_meal
  before_action :authorize

  # GET /meals/:id/edit (subdomains)
  def edit
  end

  # GET /meals/:id/log (subdomains)
  def log
  end

  private
  def set_meal
    @meal = Meal.find(params[:id])
  end

  def authorize
    if Rails.env.production?
      host = "https://"
      top_level = ".com"
    else
      host = "http://"
      top_level = ".test"
    end

    redirect_to "#{host}www.comeals#{top_level}" and return unless current_resident.present?
  end
end
