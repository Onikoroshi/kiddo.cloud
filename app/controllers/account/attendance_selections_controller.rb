class Account::AttendanceSelectionsController < ApplicationController
  before_action :guard_center!
  before_action :fetch_account

  def step
    :plan
  end

  def edit
    @account.create_default_child_attendance_selections
  end

  def update
    if @account.update_attributes(account_selection_params)
      @account.record_step(:plan)
      redirect_to account_step_path(@account, :summary), notice: "Great! You're all signed up. Let's review."
    else
      render :new
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account_child
      @account_child = Child.find(params[:id])
    end

    def fetch_account
      @account = Account.find(params[:account_id])
    end

    # Only allow a trusted parameter "white list" through.
    def account_selection_params
      permitted_attributes = [
        children_attributes: [
          :id,
          attendance_selection_attributes: [
            :id,
            :monday,
            :tuesday,
            :wednesday,
            :thursday,
            :friday,
            :saturday,
            :sunday,
          ],
        ]
      ]
      params.require(:account).permit(permitted_attributes)
    end
end
