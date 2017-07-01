class ChildrenAttendanceController < ApplicationController
  before_action :guard_center!

  # GET /interviews
  def index
    @location = Location.find(params[:location_id]) || @center.default_location
  end

end