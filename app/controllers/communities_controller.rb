class CommunitiesController < ApplicationController
  def new
  end

  def show
    community = Community.find(params[:id])

    @id = community.id
    @name = community.name
  end

end
