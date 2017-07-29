class Account::StepsController < ApplicationController
  include Wicked::Wizard
  steps :parents, :children, :medical, :plan, :summary, :payment
  before_action :authenticate_user!
  before_action :find_account
  before_action :guard_signup_complete

  def show
    authorize @account, :register?
    case step
    when :parents then show_parents
    when :children then delegate_to_account_children_controller
    when :medical then show_medical
    when :plan then delegate_to_attendance_selections
    when :summary then show_summary
    when :payment then show_payment
    end
  end

  def update
    authorize @account, :register?
    case step
    when :parents then update_parents
    when :medical then update_medical
    when :plan then update_plan
    when :summary then update_summary
    when :payment then update_payment
    end
  end

  private

  def show_parents
    @account_form = AccountForm.new(center: @center, account: @account, current_user: current_user)
    render_wizard
  end

  def update_parents
    @account_form = AccountForm.new(center: @center, account: @account, current_user: current_user)
    @account_form.assign_attributes(account_parent_params(step))
    if @account_form.submit
      @account.record_step(:parents)
      redirect_to next_wizard_path
    else
      render_wizard
    end
  end

  def delegate_to_account_children_controller
    redirect_to new_account_child_path(@account)
  end

  def delegate_to_attendance_selections
    redirect_to account_enrollment_type_path(@account)
  end

  def show_medical
    guard_children_added!
    @account_medical_form = AccountMedicalForm.new(@center, @account)
    render_wizard
  end

  def update_medical
    @account_medical_form = AccountMedicalForm.new(@center, @account)
    @account_medical_form.assign_attributes(account_medical_form_params)
    if @account_medical_form.submit
      @account.record_step(:medical)
      redirect_to next_wizard_path
    else
      render_wizard
    end
  end

  def show_summary
    @account_summary_form = AccountSummaryForm.new(@center, @account)
    render_wizard
  end

  def update_summary
    @account_summary_form = AccountSummaryForm.new(@center, @account)
    @account_summary_form.assign_attributes(account_summary_form_params)
    if @account_summary_form.submit
      @account.record_step(:summary)
      redirect_to next_wizard_path
    else
      render_wizard
    end
  end

  def show_payment
    render_wizard
  end

  def update_payment
    @account.record_step(:payment)
    finalize_signup
  end

  private

  def guard_signup_complete
    redirect_to account_dashboard_path(@account) if @account.signup_complete?
  end

  def guard_children_added!
    if @account.children.empty?
      flash[:error] = "You must add at least one child to continue."
      redirect_to new_account_child_path(@account) and return
    end
  end

  def find_account
    raise Pundit::NotAuthorizedError if !user_signed_in?
    @account ||= current_user.account
  end

  def finalize_signup
    @account.finalize_signup
    redirect_to account_dashboard_path(@account)
  end

  def account_parent_params(step)
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
     :emergency_contact_phone,
     :waiver_agreement,
     :mail_agreements
    ]
    params.require(:account_form).permit(permitted_attributes).merge(step: step)
  end

  def account_summary_form_params
    params.require(:account_summary_form).permit(:signature)
  end

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
    params.require(:account_medical_form).permit(permitted_attributes).merge(step: step)
  end
end
