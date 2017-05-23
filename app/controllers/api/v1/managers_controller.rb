module Api
  module V1
    class ManagersController < ApplicationController
      def create
        manager = Manager.new(email: params[:email], password: params[:password])
        if manager.save
          cookies.permanent[:token] = manager.key.token
          render json: { message: "Manager created.", id: manager.id, token: manager.key.token } and return
        else
          render json: { error: "Manager could not be created", message: manager.errors }, status: :bad_request and return
        end
      end
    end
  end
end
