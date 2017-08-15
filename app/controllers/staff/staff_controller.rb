class Staff::StaffController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!

  # GET /account/dashboards/1
  def index
    @staff = Staff
                .all
                .includes(:user)
                .order(created_at: :desc)
                .page(params[:page])
                .per(50)
  end
end
