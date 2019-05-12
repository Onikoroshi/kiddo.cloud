class Account::Manage::ParentsController < ApplicationController
  layout :set_layout_by_role
  before_action :guard_center!
  before_action :set_account

  def edit
    authorize @account, :dashboard?

    @account_form = AccountForm.new(center: @center, account: @account, current_user: current_user)
  end

  # PATCH/PUT /account/children/1
  def update
    authorize @account, :dashboard?

    @account_form = AccountForm.new(center: @center, account: @account, current_user: current_user)
    @account_form.assign_attributes(account_parent_params)
    if @account_form.submit
      redirect_to account_dashboard_path(@account), notice: 'Parents were successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  # Only allow a trusted parameter "white list" through.
  def account_parent_params
    permitted_attributes = [
     :parent_first_name,
     :parent_last_name,
     :parent_phone,
     :parent_email,
     :parent_street,
     :parent_extended,
     :parent_locality,
     :parent_region,
     :parent_postal_code,
     :parent_guardian_first_name,
     :parent_guardian_last_name,
     :parent_guardian_phone,
     :parent_guardian_email,
     :parent_guardian_street,
     :parent_guardian_extended,
     :parent_guardian_locality,
     :parent_guardian_region,
     :parent_guardian_postal_code,
     :emergency_contact_first_name,
     :emergency_contact_last_name,
     :emergency_contact_phone
    ]
    params.require(:account_form).permit(permitted_attributes)
  end
end
