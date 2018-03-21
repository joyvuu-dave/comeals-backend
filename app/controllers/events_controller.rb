class EventsController < ApplicationController
  before_action :set_event, only: [:edit]

  # GET /events/:id/edit (subdomains)
  def edit
  end

  # GET /events/new
  def new
  end

  private
  def set_event
    @event = Event.find(params[:id])
  end
end
