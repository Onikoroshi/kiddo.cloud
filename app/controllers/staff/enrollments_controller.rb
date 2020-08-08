class Staff::EnrollmentsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :find_enrollments, only: [:index, :export_to_csv]
  before_action :find_enrollment, only: [:edit, :update]

  def index
  end

  def export_to_csv
    send_data @enrollments.to_csv
  end

  def show
  end

  def edit
  end

  def update
    if @enrollment.update_attributes(permitted_params)
      redirect_to staff_account_path(@enrollment.account), notice: "Enrollment successfully updated"
    else
      render "edit"
    end
  end

  def set_change_refund_requirement
    respond_to do |format|
      change = EnrollmentChange.find(params[:id])
      require_refund = params[:require_refund] == "true"
      change.update_attributes(requires_refund: require_refund)

      calculator = ChildEnrollment::EnrollmentPriceCalculator.new(change.enrollment.child.account)
      calculator.calculate
      results = {amount: change.amount.to_s, total_charge_amount: calculator.total.to_s, total_refund_amount: calculator.refund_total.to_i, total_refund_string: calculator.refund_total.to_s}

      format.js {
        render json: results
      }
    end
  end

  def set_change_fee_requirement
    respond_to do |format|
      account = Account.find(params[:account_id])
      program = Program.find(params[:program_id])
      require_fee = params[:require_fee] == "true"
      account.enrollment_changes.by_program(program).pending.update_all(requires_fee: require_fee)

      calculator = ChildEnrollment::EnrollmentPriceCalculator.new(account)
      calculator.calculate
      change_fee = calculator.itemizations_by_program(program).select{|key, value| key.to_s.split("_fee_")[0] == "change"}.values.inject(Money.new(0)){|sum, amount| sum + amount}
      results = {amount: change_fee.to_s, total_charge_amount: calculator.total.to_s, total_refund_amount: calculator.refund_total.to_i, total_refund_string: calculator.refund_total.to_s}

      format.js {
        render json: results
      }
    end
  end

  private

  def find_enrollments
    @locations = current_user.manageable_locations
    @programs = @locations.programs.descending_by_updated

    @program = Program.find_by(id: params[:program_id]) || @center.current_program
    @program = @programs.first unless @programs.include?(@program)

    @locations = Location.where(id: (@locations.pluck(:id) & @program.locations.pluck(:id)))

    @location = Location.find_by(id: params[:location_id])
    @location = @locations.first if !current_user.super_admin? && !@locations.include?(@location)
    @location_id = @location.present? ? @location.id : ""

    @all_week = params["all_week"].present?

    @enrollments_date = Time.zone.parse(params[:enrollments_date].to_s)
    @enrollments_date = @enrollments_date.to_date if @enrollments_date.present?
    @enrollments_date = Time.zone.today if @enrollments_date.blank?
    @enrollments_date = @program.starts_at if @enrollments_date < @program.starts_at || @enrollments_date > @program.ends_at

    if @all_week
      @target_start = @enrollments_date.beginning_of_week
      @target_stop = @enrollments_date.end_of_week
    end

    @enrollments = Enrollment.alive.paid.non_custom

    if @all_week
      @enrollments = @enrollments.by_program_within_date_range(@program, @target_start, @target_stop)
    else
      @enrollments = @enrollments.by_program_on_date(@program, @enrollments_date)
    end

    @enrollments = @enrollments.by_location(@location).joins(:child).references(:children).reorder("enrollments.id DESC")

    @total_count = @enrollments.pluck("children.id").uniq.count

    @enrollments = @enrollments.page(params[:page]).per(50)
  end

  def find_enrollment
    @enrollment = Enrollment.find(params[:id])
    authorize @enrollment
  end

  def permitted_params
    @permitted_params ||= params[:enrollment].present? ? params.require(:enrollment).permit(:custom_price) : {}
  end
end
