class Core::StepsController < ApplicationController
  include Wicked::Wizard
  steps *Core.form_steps

  def show
    core = Core.find(params[:core_id])
    @core_form = CoreForm.new(core)
    render_wizard
  end

  def update
    core = Core.find(params[:core_id])
    @core_form = CoreForm.new(core)
    @core_form.update(core_form_params(step))
    render_wizard @core
  end

  private

    def core_form_params(step)
      permitted_attributes = case step
        when "identity"
          [children: [:first_name, :last_name]]
        when "characteristics"
          [:colour, :identifying_characteristics]
        when "instructions"
          [:special_instructions]
        end

      params.require(:core_form).permit(permitted_attributes).merge(form_step: step)
    end
end
