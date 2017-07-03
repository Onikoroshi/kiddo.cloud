class Children::AttendanceDisplayController < ApplicationController
  before_action :guard_center!

  # GET /interviews
  def index
    if params[:location_id].present?
      @location = Location.find(params[:location_id])
    else
      @location = @center.default_location
    end

  end

end