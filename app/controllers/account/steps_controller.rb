class Account::StepsController < ApplicationController
  include Wicked::Wizard
  steps :parents, :children, :plan, :medical, :summary
  before_action :find_account

  def show
    case step
    when :parents then show_parents
    when :children then delegate_to_account_children_controller
    when :plan then show_plan
    when :medical then show_medical
    when :summary then show_summary
    end
  end

  def update
    case step
    when :parents then update_parents
    when :plan then update_plan
    when :medical then update_medical
    when :summary then update_summary
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

  def show_plan
    render_wizard
  end

  def update_plan
    @account.record_step(:plan)
    render_wizard
  end

  def show_medical
    render_wizard
  end

  def update_medical
    @account.record_step(:medical)
    render_wizard
  end

  def show_summary
    @account_summary_form = AccountSummaryForm.new(@center, @account)
    render_wizard
  end

  def update_summary
    @account_summary_form = AccountSummaryForm.new(@center, @account)
    @account_summary_form.assign_attributes(account_summary_form_params.merge(current_user: current_user))
    if @account_summary_form.submit
      @account.record_step(:summary)
      redirect_to_finish_wizard_path
    else
      render_wizard
    end
  end

  private

  def find_account
    raise Pundit::NotAuthorizedError if !user_signed_in?
    @account ||= current_user.account
  end

  def redirect_to_finish_wizard_path
    next_wizard_path
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
end
