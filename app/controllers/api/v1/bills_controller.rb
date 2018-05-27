module Api
  module V1
    class BillsController < ApplicationController
      before_action :authenticate
      before_action :authorize

      # GET /bills?start=12345&end=12345
      def index
        if params[:start].present? && params[:end].present?
          bills = Bill.where(community_id: params[:community_id]).includes(:meal, { :resident => :unit }).joins(:meal).where("meals.date >= ?", params[:start]).where("meals.date <= ?", params[:end])
        else
          bills = Bill.where(community_id: params[:community_id]).includes(:meal, { :resident => :unit }).joins(:meal).all
        end

        render json: bills
      end

      def show
        render json: Bill.find_by(params[:id])
      end

      private
      def authenticate
        not_authenticated_api unless signed_in_resident_api?
      end

      def authorize
        not_authorized_api unless current_resident_api.community_id.to_s == params[:community_id]
      end
    end
  end
end
