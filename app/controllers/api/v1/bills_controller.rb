# frozen_string_literal: true

module Api
  module V1
    class BillsController < ApiController
      before_action :authenticate
      before_action :authorize

      # GET /bills?start=12345&end=12345
      def index
        bills = if params[:start].present? && params[:end].present?
                  Bill.where(community_id: params[:community_id])
                      .includes(:meal, { resident: :unit })
                      .joins(:meal)
                      .where(meals: { date: (params[:start]).. })
                      .where(meals: { date: ..(params[:end]) })
                else
                  Bill.where(community_id: params[:community_id])
                      .includes(:meal, { resident: :unit })
                      .joins(:meal)
                      .all
                end

        render json: bills
      end

      def show
        bill = Bill.find_by(id: params[:id])
        return not_found_api if bill.blank?

        render json: bill
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
