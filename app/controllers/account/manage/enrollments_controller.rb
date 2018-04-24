class Account::Manage::EnrollmentsController < ApplicationController
  layout :set_layout_by_role
  before_action :guard_center!
  before_action :fetch_account
  before_action :find_registering_program, except: :index
  before_action :set_plan_type, except: :index
  before_action :build_missing_enrollments, only: [:new, :edit]

  def index
    authorize @account, :dashboard?
    @enrollments = Enrollment.alive.where(child: @account.children).all
  end

  def new
  end

  def create
    @account.attributes = enrollment_params
    if @account.valid?
      unless overlapping_enrollments?
        @account.save
        redirect_to @account.signup_complete? ? (@account.enrollments.unpaid.any? ? new_account_dashboard_payment_path(@account) : account_dashboard_path(@account)) : account_step_path(@account, :plan), notice: "enrollment successful!"
      else
        render "new"
      end
    else
      render "new"
    end
  end

  def edit
    if @plan_type.present?
      changed_params = @account.enrollment_changes.build_params
      ap changed_params
      @account.attributes = changed_params
    end
  end

  def update
    redirect_to new_account_dashboard_enrollment_path(@account, plan_type: @plan_type.to_s) unless @account.signup_complete?

    # assign attributes without saving to the database.
    # don't apply any extra scopes to associations, or these changes will be lost
    @account.attributes = enrollment_params
    if @account.valid?
      unless overlapping_enrollments?
        @account.children.each do |child|
          ap "looking at child #{child.id}"
          # do NOT add any scopes to this. It will lose the attributes assigned above
          child.enrollments.each do |enrollment|
            next unless enrollment.alive?

            ap "enrollment destroy: #{enrollment._destroy}"
            if enrollment.id.blank?
              ap "creating"
              enrollment.save
            elsif enrollment.unpaid?
              ap "applying to unpaid"
              enrollment.save
            elsif enrollment._destroy || enrollment.changed?
              enrollment_change = EnrollmentChange.where(account: @account, enrollment: enrollment, applied: false).first_or_create!
              enrollment_change.update_attributes(requires_fee: true, requires_refund: true)

              if enrollment._destroy
                ap "removing #{enrollment.id}"
                enrollment_change.update_attributes(data: {"_destroy" => "true"})
              elsif enrollment.changed?
                ap "changing #{enrollment.id}"
                change_hash = {}
                enrollment.changes.each do |attr_name, change_array|
                  change_hash[attr_name] = change_array[1]
                end
                enrollment_change.update_attributes(data: change_hash)
              end
            end
          end
        end

        redirect_to edit_account_dashboard_enrollments_path(@account), notice: "Change has been initialized. Don't forget to finalize it!"
      else
        render "edit"
      end
    else
      render "edit"
    end
  end

  private

  def overlapping_enrollments?
    overlaps = false

    @account.children.each do |child|
      target_enrollments = []
      # do NOT add any scopes to this. It will lose the attributes assigned
      child.enrollments.each do |enrollment|
        target_enrollments << enrollment if enrollment.alive? && enrollment.program == @program
      end
      overlapping = child.overlapping_enrollment_dates(target_enrollments)
      if overlapping.any?
        overlaps = true
        overlapping.each do |message|
          @account.errors.add(:base, message)
        end
      end
    end

    overlaps
  end

  def fetch_account
    @account = Account.find(params[:account_id])
  end

  def set_plan_type
    @plan_type = PlanType[params[:plan_type]]
  end

  def build_missing_enrollments
    # only recurring types need pre-built objects for the form to work
    return if @plan_type.blank? || !@plan_type.recurring?

    @account.children.each do |child|
      next if child.enrollments.by_program_and_plan_type(@program, @plan_type).any?

      child.enrollments.build(program: @program, plan: Plan.by_plan_type(@plan_type).first)
    end
  end

  def enrollment_params
    params.require(:account).permit(:payment_offset, children_attributes: [:id, enrollments_attributes: [:id, :plan_id, :child_id, :location_id, :starts_at, :ends_at, :monday, :tuesday, :wednesday, :thursday, :friday, :_destroy]])
  end
end
