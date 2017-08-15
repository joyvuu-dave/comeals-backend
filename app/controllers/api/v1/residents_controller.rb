module Api
  module V1
    class ResidentsController < ApplicationController
      def show
        resident = Resident.find_by(id: params[:id])
        render json: resident
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

      # POST
      def password_reset
        resident = Resident.find_by(email: params[:email])

        unless resident.present?
          render json: { message: 'No resident with that email address.' }, status: :bad_request and return
        end

        resident.reset_password_token = SecureRandom.urlsafe_base64
        if resident.save
          ResidentMailer.password_reset_email(resident).deliver_now
          render json: { message: 'Check your email to reset your password.' } and return
        else
          render json: { message: 'Error. Please try again.' }, status: :bad_request and return
        end
      end

      # POST
      def password_new
        resident = Resident.find_by(reset_password_token: params[:token])

        unless resident.present?
          render json: { message: 'Error.' }, status: :bad_request and return
        end

        resident.password = params[:password]

        if resident.save
          render json: { message: 'Password was updated!' } and return
        else
          render json: { message: 'Invalid password.' }, status: :bad_request and return
        end
      end

    end
  end
end
