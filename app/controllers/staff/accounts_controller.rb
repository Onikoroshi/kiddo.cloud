class Staff::AccountsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!

  # GET /account/dashboards/1
  def index
    @accounts = Account
      .where(center: @center)
      .where(signup_complete: true)
      .sort_by_column_type(params[:sort], params[:sort_dir])
      .page(params[:page])
      .per(50)
  end
end
