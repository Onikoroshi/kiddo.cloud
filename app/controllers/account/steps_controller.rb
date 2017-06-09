class Account::StepsController < ApplicationController
  include Wicked::Wizard
  steps *Account.form_steps

  def show
    account = Account.find(params[:account_id])
    @account_form = AccountForm.new(account, step)
    render_wizard
  end

  def update
    account = Account.find(params[:account_id])
    @account_form = AccountForm.new(account, step)
    if @account_form.update(account_form_params(step))
      redirect_to next_wizard_path
    else
      render_wizard
    end
  end

  private

    def account_form_params(step)
      permitted_attributes = case step
        when "identity"
          [
           children: [:first_name, :last_name, :grade_entering, :birthdate, :additional_info, :gender],
           parents:  [:first_name, :last_name, :street, :extended, :locality, :region, :postal_code]
          ]
        when "characteristics"
          [:colour, :identifying_characteristics]
        when "instructions"
          [:special_instructions]
        end

      params.require(:account_form).permit(permitted_attributes).merge(form_step: step)
    end
end
