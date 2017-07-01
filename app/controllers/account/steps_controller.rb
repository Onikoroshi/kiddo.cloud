class Account::StepsController < ApplicationController
  include Wicked::Wizard
  steps :parents, :children, :plan, :medical, :summary

  def show
    case step
    when :parents then show_parents
    when :children then show_children
    end
  end

  def update
    case step
    when :parents then update_parents
    when :children then update_children
    end
  end

  private

  def show_parents
    @account_form = AccountForm.new
    @account_form.assign_attributes(current_user: current_user)
    render_wizard
  end

  def update_parents
    @account_form = AccountForm.new(account_form_params(:parents))
    if @account_form.save
      redirect_to next_wizard_path
    else
      render_wizard
    end
  end

  def show_children
  end

  def update_children
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
