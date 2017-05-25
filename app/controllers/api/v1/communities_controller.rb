module Api
  module V1
    class CommunitiesController < ApplicationController
      def create
        render json: { id: 1, slug: 'swans' }
      end

      def show
        render json: { id: 1, name: "Swans's Way" }
      end
    end
  end
end
