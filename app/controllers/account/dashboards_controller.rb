class Account::DashboardsController < ApplicationController
  layout :set_layout

  before_action :guard_center!
  before_action :set_account
  before_action :guard_signup_complete

  # GET /account/dashboards/1
  def show
    authorize @account, :dashboard?
  end

  def change_request
  end

  private

  def set_layout
    current_user.parent? ? "dkk_customer_dashboard" : "dkk_staff_dashboard"
  end

  def guard_signup_complete
    return unless current_user.parent?

    account = current_user.account
    if !account.signup_complete
      flash[:message] = "Let's finish registering."
      redirect_to account_step_path(account,
        account.last_registration_step_completed.to_sym) && return
    end
  end

  def set_account
    @account = Account.find(params[:account_id])
  end
end
