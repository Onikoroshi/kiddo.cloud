class Staff::AccountsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!

  # GET /account/dashboards/1
  def index
    @accounts = Account
                .includes(:parents)
                .where(center: @center)
                .where(signup_complete: true)
                .page(params[:page])
                .per(50)
  end

  def show
    @account = Account.find(params[:id])
  end
end
