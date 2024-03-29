class Staff::PlansController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :authorize_multiple, only: :index
  before_action :build_single, only: [:new, :create]
  before_action :find_single, only: [:show, :edit, :update, :destroy, :reenable]
  before_action :authorize_single, except: :index

  def index
    set_collection
    @plans = @plans.page(params[:page]).per(50)
    @disabled_plans = @disabled_plans.page(params[:page]).per(50)
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
    notice = "Only Plans with no enrollments can be removed."
    if @plan.can_destroy?
      @plan.destroy
      notice = "Plan completely removed."
    elsif @plan.can_disable?
      @plan.disable!
      notice = "Plan could not be removed, but has been disabled so parents can no longer choose it as an option."
    end

    redirect_to staff_plans_path(program_id: params[:program_id]), notice: notice
  end

  def reenable
    @plan.enable!
    redirect_to staff_plans_path(program_id: params[:program_id]), notice: "Plan has been successfully Re Enabled"
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
    @disabled_plans = Plan.unscoped.by_program(@program).disabled
  end

  def build_single
    @plan = Plan.new(permitted_params)
  end

  def find_single
    @plan = Plan.unscoped.find(params[:id])
  end

  def permitted_params
    @permitted_params ||= params[:plan].present? ? params.require(:plan).permit(:program_id, :display_name, :deduce, :days_per_week, :price, :plan_type, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, discounts_attributes: [:id, :plan_id, :amount, :starts_on, :stops_on, :_destroy], target_days_attributes: [:id, :plan_id, :target_date, :_destroy]) : {}
  end
end
