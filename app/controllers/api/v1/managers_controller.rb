module Api
  module V1
    class ManagersController < ApplicationController
      def create
        manager = Manager.new(email: params[:email], password: params[:password])
        if manager.save
          cookies.permanent[:token] = manager.key.token
          render json: { id: manager.id, token: manager.key.token } and return
        else
          render json: { message: manager.errors }, status: :bad_request and return
        end
      end

      def token
        manager = Manager.find_by(email: params[:email])
        if manager.blank?
          render json: { message: "No manager with email #{params[:email]}" }, status: :bad_request and return
        end

        if manager.present? && manager.authenticate(params[:password])
          render json: { id: manager.id, token: manager.key.token } and return
        else
          render json: { message: "Incorrect password" }, status: :bad_request and return
        end
      end

      def communities
        render json: { communities: Array(current_manager&.communities) }
      end

    end
  end
end
