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
    end
  end

  def update
    case step
    when :parents then update_parents
    when :plan then update_plan
    when :medical then update_medical
    end
  end

  private

  def show_parents
    @account_form = AccountForm.new(@center, nil)
    @account_form.assign_attributes(current_user: current_user)
    render_wizard
  end

  def update_parents
    @account_form = AccountForm.new(@center, @account)
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

  private

  def find_account
    raise Pundit::NotAuthorizedError if !user_signed_in?
    @account ||= Account.find_by(id: params[:account_id])
  end


    def account_form_params(step)
      permitted_attributes = case step
        when :parents
          [
           parents_attributes:  [:phone, :street, :extended, :locality, :region, :postal_code, user_attributes: [:id, :first_name, :last_name]],
           contacts_attributes: [:first_name, :last_name, :phone]
          ]
        when "characteristics"
          [:colour, :identifying_characteristics]
        when "instructions"
          [:special_instructions]
        end

      params.require(:account_form).permit(permitted_attributes).merge(step: step)
    end
end
