class Account::Manage::PaymentsController < ApplicationController
  layout "dkk_customer_dashboard"
  before_action :guard_center!
  before_action :fetch_account

  def new
  end

  def create
  end

end
