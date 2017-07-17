module Api
  module V1
    class CommunitiesController < ApplicationController
      def create
        community = Community.new(name: params[:name])
        if community.save
          render json: community and return
        else
          render json: { message: community.errors.first[1] }, status: :bad_request and return
        end
      end

      def show
        render json: { id: 1, name: "Swans's Way" }
      end
    end
  end
end
