class Staff::AttendanceDisplayController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!

  # GET /interviews
  def index
    @location = Location.find(params[:location_id]) if params[:location_id].present?
  end

end
