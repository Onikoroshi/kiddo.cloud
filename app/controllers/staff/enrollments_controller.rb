class Staff::EnrollmentsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!

  def index
    @location_id = params[:location_id].present? ? params[:location_id] : Location.first.id 
    @enrollments = Enrollment
      .includes(:location)
      .where(location_id: @location_id)
      .order(created_at: :desc)
      .page(params[:page])
      .per(50)
  end

  def show; end
end
