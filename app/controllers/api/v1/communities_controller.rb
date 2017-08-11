module Api
  module V1
    class CommunitiesController < ApplicationController
      def create
        community = Community.new(name: params[:name], admin_users_attributes: [{ email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation]}])
        if community.save
          render json: { message: "#{community.name} has been created." } and return
        else
          render json: { message: community.errors.first[1] }, status: :bad_request and return
        end
      end

    end
  end
end
