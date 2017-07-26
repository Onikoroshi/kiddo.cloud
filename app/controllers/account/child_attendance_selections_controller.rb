class Account::ChildAttendanceSelectionsController < ApplicationController
  before_action :guard_center!
  before_action :set_account

  # GET /account/children/1/edit
  def edit
  end

  # PATCH/PUT /account/children/1
  def update
    if @account_child.update(account_child_params)
      redirect_to account_children_path(@account), notice: 'Child was successfully updated.'
    else

      render :edit
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account_child
      @account_child = Child.find(params[:id])
    end

    def set_account
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
