module Api
  module V1
    class CommunitiesController < ApplicationController
      def show
        render json: { community: { id: 1, name: "Swans's Way" } }
      end
    end
  end
end
