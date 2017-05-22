module Api
  module V1
    class ResidentsController < ApplicationController
      def show
        render json: { resident: { id: 1, name: 'David' } }
      end
    end
  end
end
