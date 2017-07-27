class Account::AttendanceSelectionsController < ApplicationController
  before_action :guard_center!
  before_action :fetch_account

  def step
    :plan
  end

  def new
    @account.children.map { |c| c.attendance_selections.build }
  end

  # PATCH/PUT /account/children/1
  def create
    debugger
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
    def account_child_params
      permitted_attributes = [
       :first_name,
       :last_name,
       :gender,
       :grade_entering,
       :birthdate,
       :additional_info,
       care_items_attributes: [:id, :name, :active, :explanation],
       attendance_selections_attributes: []
      ]
      params.require(:child).permit(permitted_attributes)
    end
end
