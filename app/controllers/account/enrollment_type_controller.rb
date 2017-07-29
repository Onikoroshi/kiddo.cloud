class Account::EnrollmentTypeController < ApplicationController
  before_action :guard_center!
  before_action :fetch_account

  def step
    :plan
  end

  def show
    #authorize
  end

  private

  def fetch_account
    @account = Account.find(params[:account_id])
  end

end
