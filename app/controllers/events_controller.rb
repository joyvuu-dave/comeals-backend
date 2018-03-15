class EventsController < ApplicationController
  before_action :set_event

  # GET /events/:id/edit (subdomains)
  def edit
  end

  private
  def set_event
    @event = Event.find(params[:id])
  end
end
