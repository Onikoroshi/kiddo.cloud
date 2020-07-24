class Staff::ProgramsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :authorize_multiple, only: :index
  before_action :build_single, only: [:new, :create]
  before_action :find_single, only: [:show, :edit, :update, :destroy]
  before_action :authorize_single, except: :index
  before_action :build_payment_offsets, only: [:new, :edit]

  def index
    set_collection
    @programs = @programs.page(params[:page]).per(50)
  end

  def new
  end

  def create
    if @program.save
      redirect_to staff_programs_path, notice: "Program successfully created."
    else
      build_payment_offsets
      render "new"
    end
  end

  def edit
  end

  def update
    if @program.update_attributes(permitted_params)
      redirect_to staff_programs_path, notice: "Program successfully updated."
    else
      build_payment_offsets
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
    @programs = @center.programs.descending_by_updated
  end

  def build_single
    @program = Program.new(permitted_params)
  end

  def find_single
    @program = Program.find(params[:id])
  end

  def build_payment_offsets
    @payment_offsets = PaymentOffsetPresenter.build(-15, 14)
  end

  def permitted_params
    @permitted_params ||= params[:program].present? ? params.require(:program).permit(:center_id, :program_group_id, :program_type, :name, :priority, :starts_at, :ends_at, :registration_opens, :registration_closes, :registration_fee, :change_fee, :earliest_payment_offset, :latest_payment_offset, :disable_refunds, :custom_requests, :custom_requests_url, allowed_grades: [], location_ids: [], plan_ids: [], holidays_attributes: [:id, :program_id, :holidate, :_destroy]) : {}
  end
end
