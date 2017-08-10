module Api
  module V1
    class CommunitiesController < ApplicationController
      def create
        community = Community.new(name: params[:name])

        ### VALIDATE STUFF

        # Scenario #1: Invalid community name
        if !community.valid?
          render json: { message: 'Invalid community name.' }, status: :bad_request and return
        end

        # Scenario #2: AdminUser exists - bad password
        if AdminUser.exists?(email: params[:email]) && !Admin.find_by(email: params[:email]).valid_password?(params[:password])
          render json: { message: 'Incorrect password for existing Manager.' }, status: :bad_request and return
        end

        # Scenario #3: AdminUser does not exist - invalid
        admin_user = AdminUser.new(email: params[:email], password: params[:password], password_confirmation: params[:password])
        if !admin_user.valid?
          render json: { message: 'Invalid email or password for new Manager.' }, status: :bad_request and return
        end

        ### SAVE STUFF

        # Scenario #1: existing AdminUser
        admin_user = AdminUser.find_by(email: params[:email])
        if admin_user.present? && admin_user.valid_password?(params[:password])
          if community.save
            community_admin_user = CommunityAdminUser.new(community_id: community.id, admin_user_id: admin_user.id)
            if community_admin_user.save
              render json: { message: 'Community created!' } and return
            else
              render json: { message: 'Existing Manager could not be added to Community!' }, status: :bad_request and return
            end
          else
            render json: { message: 'Community could not be created!' }, status: :bad_request and return
          end
        end

        # Scenario #2: no existing AdminUser
        admin_user = AdminUser.new(email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation])
        community = Community.new(name: params[:name])


        if admin_user.save && community.save
          community_admin_user = CommunityAdminUser.new(community_id: community.id, admin_user_id: admin_user.id)
          if community_admin_user.save
            render json: { message: 'Community and Manager created!' } and return
          else
            render json: { message: 'New Manager could not be added to Community' }, status: :bad_request and return
          end
        else
          array = []
          array.push("Manager") unless admin_user.persisted?
          array.push("Community") unless community.persisted?
          render json: { message: "#{array.inspect} not created!"}, status: :bad_request and return
        end
      end

      def show
        render json: { id: 1, name: "Swans's Way" }
      end
    end
  end
end
