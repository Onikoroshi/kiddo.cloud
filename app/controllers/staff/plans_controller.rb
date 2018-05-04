class Staff::PlansController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :authorize_multiple, only: :index
  before_action :build_single, only: [:new, :create]
  before_action :find_single, only: [:show, :edit, :update, :destroy]
  before_action :authorize_single, except: :index

  def index
    set_collection
    @plans = @plans.page(params[:page]).per(50)
  end

  def new
  end

  def create
    if @plan.save
      redirect_to staff_plans_path(program_id: params[:program_id]), notice: "Plan successfully created."
    else
      render "new"
    end
  end

  def edit
  end

  def update
    if @plan.update_attributes(permitted_params)
      redirect_to staff_plans_path(program_id: params[:program_id]), notice: "Plan successfully updated."
    else
      render "edit"
    end
  end

  def destroy
    if @plan.can_destroy?
      @plan.destroy
      redirect_to staff_plans_path(program_id: params[:program_id]), notice: "Plan completely removed."
    else
      redirect_to staff_plans_path(program_id: params[:program_id]), notice: "Only Plans with no enrollments or transactions can be removed."
    end
  end

  private

  def authorize_multiple
    authorize Plan
  end

  def authorize_single
    authorize @plan
  end

  def set_collection
    @program = Program.find_by(id: params[:program_id])
    @program_id = @program.present? ? @program.id : ""

    @plans = Plan.by_program(@program)
  end

  def build_single
    @plan = Plan.new(permitted_params)
  end

  def find_single
    @plan = Plan.find(params[:id])
  end

  def permitted_params
    @permitted_params ||= params[:plan].present? ? params.require(:plan).permit(:program_id, :display_name, :deduce, :days_per_week, :price, :plan_type, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, discounts_attributes: [:id, :plan_id, :amount, :month, :_destroy]) : {}
  end
end
