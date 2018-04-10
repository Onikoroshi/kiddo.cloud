class Staff::EnrollmentsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!

  def index
    @location_id = params[:location_id].present? ? params[:location_id] : Location.first.id
    @enrollments = Enrollment
      .includes(:location)
      .where(location_id: @location_id)
      .order(created_at: :desc)
      .page(params[:page])
      .per(50)
  end

  def show; end

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
end
