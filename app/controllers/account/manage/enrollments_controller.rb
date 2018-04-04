class Account::Manage::EnrollmentsController < ApplicationController
  layout :set_layout_by_role
  before_action :guard_center!
  before_action :fetch_account
  before_action :find_registering_program, except: :index

  def index
    authorize @account, :dashboard?
    @enrollments = Enrollment.where(child: @account.children).all
  end

  def new
    @plan_type = PlanType[params[:plan_type]]

    @account.children.each do |child|
      next if child.enrollments.by_program_and_plan_type(@program, @plan_type).any?

      child.enrollments.build(program: @program, plan: Plan.by_plan_type(@plan_type).first)
    end

    render layout: current_user.parent? ? (@account.signup_complete? ? "dkk_customer_dashboard" : "davis_kids_klub") : "dkk_staff_dashboard"
  end

  def create
    if @account.update_attributes(enrollment_params)
      success = true

      @account.children.each do |child|
        overlapping = child.overlapping_enrollment_dates(@program)
        if overlapping.any?
          success = false
          overlapping.each do |message|
            @account.errors.add(:base, message)
          end
        end
      end

      if success
        redirect_to @account.signup_complete? ? (@account.enrollments.unpaid.any? ? new_account_dashboard_payment_path(@account) : account_dashboard_enrollments_path(@account)) : account_step_path(@account, :plan), notice: "enrollment successful!"
      else
        @plan_type = PlanType[params[:plan_type]]
        render "new"
      end
    else
      @plan_type = PlanType[params[:plan_type]]
      render "new"
    end
  end

  private

  def fetch_account
    @account = Account.find(params[:account_id])
  end

  def enrollment_params
    params.require(:account).permit(children_attributes: [:id, enrollments_attributes: [:id, :plan_id, :child_id, :location_id, :starts_at, :ends_at, :monday, :tuesday, :wednesday, :thursday, :friday, :_destroy]])
  end
end
