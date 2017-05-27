module Api
  module V1
    class ResidentsController < ApplicationController
      def show
        render json: { resident: { id: 1, name: 'David' } }
      end

      def token
        resident = Resident.find_by(email: params[:email])
        if resident.blank?
          render json: { message: "No resident with email #{params[:email]}" }, status: :bad_request and return
        end

        if resident.present? && resident.authenticate(params[:password])
          render json: { token: resident.key.token, slug: resident.community.slug } and return
        else
          render json: { message: "Incorrect password" }, status: :bad_request and return
        end
      end

    end
  end
end
