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
      results = {amount: change.amount.to_s, total_charge_amount: calculator.total.to_s, total_refund_amount: calculator.refund_total}

      format.js {
        render json: results
      }
    end
  end

  def set_change_fee_requirement
    respond_to do |format|
      account = Account.find(params[:account_id])
      require_fee = params[:require_fee] == "true"
      account.enrollment_changes.pending.update_all(requires_fee: require_fee)

      calculator = ChildEnrollment::EnrollmentPriceCalculator.new(account)
      calculator.calculate
      change_fee = calculator.itemizations[:change_fee] || Money.new(0)
      results = {amount: change_fee.to_s, total_charge_amount: calculator.total.to_s, total_refund_amount: calculator.refund_total}

      format.js {
        render json: results
      }
    end
  end

  private

  def find_enrollments
    @program = Program.find_by(id: params[:program_id]) || @center.current_program
    @location = Location.find_by(id: params[:location_id])
    @location_id = @location.present? ? @location.id : ""

    @enrollments_date = Time.zone.parse(params[:enrollments_date].to_s)
    @enrollments_date = @enrollments_date.to_date if @enrollments_date.present?
    @enrollments_date = Time.zone.today if @enrollments_date.blank?
    @enrollments_date = @program.starts_at if @enrollments_date < @program.starts_at || @enrollments_date > @program.ends_at

    @enrollments = Enrollment.alive
      .by_program(@program)
      .by_location(@location)
      .for_date(@enrollments_date)
      .order(created_at: :desc)
      .page(params[:page])
      .per(50)
  end
end
