class Account::Manage::MedicalController < ApplicationController
  layout :set_layout
  before_action :guard_center!
  before_action :set_account

  def edit
    authorize @account, :dashboard?

    @account_medical_form = AccountMedicalForm.new(@center, @account)
  end

  def update
    authorize @account, :dashboard?

    @account_medical_form = AccountMedicalForm.new(@center, @account)
    @account_medical_form.assign_attributes(account_medical_form_params)
    if @account_medical_form.submit
      redirect_to account_dashboard_path(@account), notice: 'Medical Information successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_layout
    current_user.role?("parent") ? "dkk_customer_dashboard" : "dkk_staff_dashboard"
  end

  def set_account
    @account = Account.find(params[:account_id])
  end

  # Only allow a trusted parameter "white list" through.
  def account_medical_form_params
    permitted_attributes = [
      :family_physician,
      :physician_phone,
      :family_dentist,
      :dentist_phone,
      :insurance_company,
      :insurance_policy_number,
      :medical_waiver_agreement
    ]
    params.require(:account_medical_form).permit(permitted_attributes)
  end
end
