class Account::DashboardsController < ApplicationController
  layout "dkk_customer_dashboard"
  before_action :guard_center!
  before_action :set_account
  before_action :guard_signup_complete

  # GET /account/dashboards/1
  def show
    authorize @account, :dashboard?
  end

  private

  def guard_signup_complete
    if !@account.signup_complete
      flash[:message] = "Let's finish registering."
      redirect_to account_step_path(@account,
        @account.last_registration_step_completed.to_sym) and return
    end
  end

  def set_account
    @account = current_user.account
  end

end
