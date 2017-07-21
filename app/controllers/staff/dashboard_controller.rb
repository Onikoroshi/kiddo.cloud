class Staff::DashboardController < ApplicationController
  before_action :guard_center!

  # GET /account/dashboards/1
  def show
    authorize :center_dashboard, :show?
  end

  private

  def set_account
    @account = current_user.account
  end

end
