module Api
  module V1
    class BillsController < ApplicationController
      def index
        # FIXME: filter by community
        if params[:start].present? && params[:end].present?
          bills = Bill.includes(:meal, { :resident => :unit }).joins(:meal).where("meals.date >= ?", params[:start]).where("meals.date <= ?", params[:end])
        else
          bills = Bill.includes(:meal, { :resident => :unit }).joins(:meal).all
        end

        render json: bills
      end

      def show
        render json: Bill.find_by(params[:id])
      end

    end
  end
end
