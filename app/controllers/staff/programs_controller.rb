class Staff::ProgramsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :authorize_multiple, only: :index
  before_action :build_single, only: [:new, :create]
  before_action :find_single, only: [:show, :edit, :update, :destroy]
  before_action :authorize_single, except: :index

  def index
    set_collection
    @programs = @programs.page(params[:page]).per(50)
  end

  def new
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
    if @program.update_attributes(permitted_params)
      redirect_to staff_programs_path, notice: "Program completely updated."
    else
      render "edit"
    end
  end

  def destroy
    if @program.can_destroy?
      @program.destroy
      redirect_to staff_programs_path, notice: "Program completely removed."
    else
      redirect_to staff_programs_path, notice: "Only Programs with no locations, plans, enrollments, or transactions can be removed."
    end
  end

  private

  def authorize_multiple
    authorize Program
  end

  def authorize_single
    authorize @program
  end

  def set_collection
    @programs = @center.programs
  end

  def build_single
    @program = Program.new(permitted_params)
  end

  def find_single
    @program = Program.find(params[:id])
  end

  def permitted_params
    @permitted_params ||= params[:program].present? ? params.require(:program).permit(:center_id, :short_code, :name, :starts_at, :ends_at, :registration_opens, :registration_closes, :registration_fee, :change_fee, location_ids: [], plan_ids: []) : {}
  end
end
