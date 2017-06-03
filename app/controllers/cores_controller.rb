class CoresController < ApplicationController
  before_action :require_center!
  before_action :set_core, only: [:show, :edit, :update, :destroy]

  # GET /cores
  # GET /cores.json
  def index
    # Normally you'd have more complex requirements about
    # when not to show rows, but we don't show any records that don't have a name
    @cores = Core.where.not(name: nil)
  end

  # GET /cores/1
  # GET /cores/1.json
  def show
  end

  # GET /cores/new
  def new
    @core = Core.new
  end

  # POST /cores
  # POST /cores.json
  def create
    @core = Core.new
    @core.save(validate: false)
    redirect_to core_step_path(@core, Core.form_steps.first)
  end

  # DELETE /cores/1
  # DELETE /cores/1.json
  def destroy
    @core.destroy
    respond_to do |format|
      format.html { redirect_to cores_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_core
      @core = Core.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def core_params
      params.require(:core).permit(:name, :colour, :owner_name, :identifying_characteristics, :special_instructions)
    end
end