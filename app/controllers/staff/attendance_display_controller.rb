class Staff::AttendanceDisplayController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!

  # GET /interviews
  def index
    selected_location = Location.find(params[:location_id]) if params[:location_id].present?
    @location = selected_location || @center.default_location
  end

end
