class Account::Manage::EnrollmentsController < ApplicationController
  layout "dkk_customer_dashboard"
  before_action :guard_center!
  before_action :fetch_account

  def index
    @enrollments = Enrollment.where(child: @account.children).all
  end


  private

    def fetch_account
      @account = Account.find(params[:account_id])
    end

end
