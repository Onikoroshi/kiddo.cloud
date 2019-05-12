class Staff::ProgramGroupsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :authorize_multiple, only: :index
  before_action :build_single, only: [:new, :create]
  before_action :find_single, only: [:show, :edit, :update, :destroy]
  before_action :authorize_single, except: :index

  def index
    set_collection
    @program_groups = @program_groups.page(params[:page]).per(50)
  end

  def new
  end

  def create
    if @program_group.save
      redirect_to staff_program_groups_path, notice: "ProgramGroup successfully created."
    else
      render "new"
    end
  end

  def edit
  end

  def update
    if @program_group.update_attributes(permitted_params)
      redirect_to staff_program_groups_path, notice: "ProgramGroup successfully updated."
    else
      render "edit"
    end
  end

  def destroy
    if @program_group.can_destroy?
      @program_group.destroy
      redirect_to staff_program_groups_path, notice: "Program Group completely removed."
    else
      redirect_to staff_program_groups_path, notice: "Program Group could not be removed"
    end
  end

  private

  def authorize_multiple
    authorize ProgramGroup
  end

  def authorize_single
    authorize @program_group
  end

  def set_collection
    @program_groups = @center.program_groups
  end

  def build_single
    @program_group = ProgramGroup.new(permitted_params)
  end

  def find_single
    @program_group = ProgramGroup.find(params[:id])
  end

  def permitted_params
    @permitted_params ||= params[:program_group].present? ? params.require(:program_group).permit(:center_id, :title) : {}
  end
end
