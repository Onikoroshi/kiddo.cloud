class Staff::AccountsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!

  # GET /account/dashboards/1
  def index
    @accounts = Account.includes(:parents).all.order(created_at: :desc)
  end
end
