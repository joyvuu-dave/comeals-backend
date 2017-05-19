module Api
  module V1
    class ResidentsController < ApplicationController
      def show
        render json: { resident: { name: 'David', id: 1 } }
      end
    end
  end
end
