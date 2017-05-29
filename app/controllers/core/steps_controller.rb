class Core::StepsController < ApplicationController
  include Wicked::Wizard
  steps *Core.form_steps

  def show
    @core = Core.find(params[:core_id])
    render_wizard
  end

  def update
    @core = Core.find(params[:core_id])
    @core.update(core_params(step))
    render_wizard @core
  end

  private

    def core_params(step)
      permitted_attributes = case step
        when "identity"
          [:name, :owner_name]
        when "characteristics"
          [:colour, :identifying_characteristics]
        when "instructions"
          [:special_instructions]
        end

      params.require(:core).permit(permitted_attributes).merge(form_step: step)
    end
end
