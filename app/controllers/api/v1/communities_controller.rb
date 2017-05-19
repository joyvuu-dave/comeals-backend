module Api
  module V1
    class CommunitiesController < ApplicationController
      def show
        render json: { community: { name: "Swans's Way" } }
      end
    end
  end
end
