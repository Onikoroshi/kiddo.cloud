class Staff::EnrollmentsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :find_enrollments, only: [:index, :export_to_csv]

  def index
  end

  def export_to_csv
    send_data @enrollments.to_csv
  end

  def show
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
    @programs = @locations.programs

    @program = Program.find_by(id: params[:program_id]) || @center.current_program
    @program = @programs.first unless @programs.include?(@program)

    @locations = Location.where(id: (@locations.pluck(:id) & @program.locations.pluck(:id)))

    @location = Location.find_by(id: params[:location_id])
    @location = @locations.first if !current_user.super_admin? && !@locations.include?(@location)
    @location_id = @location.present? ? @location.id : ""

    @enrollments_date = Time.zone.parse(params[:enrollments_date].to_s)
    @enrollments_date = @enrollments_date.to_date if @enrollments_date.present?
    @enrollments_date = Time.zone.today if @enrollments_date.blank?
    @enrollments_date = @program.starts_at if @enrollments_date < @program.starts_at || @enrollments_date > @program.ends_at

    @enrollments = Enrollment.alive.paid
      .by_program(@program)
      .by_location(@location)
      .for_date(@enrollments_date)
      .order(created_at: :desc)
      .page(params[:page])
      .per(50)
  end
end
