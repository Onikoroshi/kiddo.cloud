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
    if @plan_type.present?
      changed_params = @account.enrollment_changes.pending.build_params
      @account.attributes = changed_params
    end

    build_day_ids
  end

  def create
    # apply any enrollment-independent changes
    @account.update_attributes(account_params)

    # assign attributes without saving to the database.
    # don't apply any extra scopes to associations, or these changes will be lost

    # first, apply any other changes that are pending
    unapplied_change_params = @account.enrollment_changes.pending.build_params
    @account.attributes = unapplied_change_params

    # now apply the ones we just chose
    @account.attributes = enrollment_params

    if @account.valid?
      unless overlapping_enrollments?
        @account.children.each do |child|
          ap "looking at child #{child.id}"
          # do NOT add any scopes to this. It will lose the attributes assigned above
          child.enrollments.each do |enrollment|
            next unless enrollment.alive?

            if enrollment._destroy
              ap "destroying unpaid #{enrollment.id}"
              enrollment.destroy
            end
          end
        end

        @account.save
        path = @account.signup_complete? ? (@account.enrollments.unpaid.any? ? new_account_dashboard_payment_path(@account) : account_dashboard_path(@account)) : (@account.enrollments.any? ? account_step_path(@account, :summary) : account_step_path(@account, :plan))
        redirect_to path, notice: @account.enrollments.any? ? "enrollment successful!" : "no enrollment chosen"
      else
        build_missing_enrollments
        build_day_ids
        render "new"
      end
    else
      build_missing_enrollments
      build_day_ids
      render "new"
    end
  end

  def edit
    if @plan_type.present?
      changed_params = @account.enrollment_changes.pending.build_params
      @account.attributes = changed_params
    end

    build_day_ids
  end

  def update
    redirect_to new_account_dashboard_enrollment_path(@account, plan_type: @plan_type.to_s) and return unless @account.signup_complete? || policy(Transaction).manage?

    # apply any enrollment-independent changes
    @account.update_attributes(account_params)

    # assign attributes without saving to the database.
    # don't apply any extra scopes to associations, or these changes will be lost

    # first, apply any other changes that are pending
    unapplied_change_params = @account.enrollment_changes.pending.build_params
    @account.attributes = unapplied_change_params

    # now apply the ones we just chose
    @account.attributes = enrollment_params
    if @account.valid?
      unless overlapping_enrollments?
        @account.children.each do |child|
          ap "looking at child #{child.id}"
          # do NOT add any scopes to this. It will lose the attributes assigned above
          child.enrollments.each do |enrollment|
            next unless enrollment.alive?

            if enrollment.id.blank?
              ap "creating"
              enrollment.save
            elsif enrollment.unpaid? && enrollment.transactions.none? # we can have an unpaid recurring enrollment that still needs changed
              if enrollment._destroy
                ap "destroying unpaid #{enrollment.id}"
                enrollment.destroy
              elsif enrollment.changed?
                ap "saving unpaid #{enrollment.id}"
                enrollment.save
              else
                ap "unpaid #{enrollment.id} didn't change"
              end

              EnrollmentChange.where(account: @account, enrollment: enrollment, applied: false).destroy_all
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
            elsif !enrollment.changed?
              ap "#{enrollment.plan_type} #{enrollment.id} not changed, destroying extraneous changes"
              EnrollmentChange.where(account: @account, enrollment: enrollment, applied: false).destroy_all
            else
              ap "nothing"
            end
          end
        end

        redirect_to edit_account_dashboard_enrollments_path(@account), notice: "Change has been initialized. Don't forget to finalize it!"
      else
        build_missing_enrollments
        build_day_ids
        render "edit"
      end
    else
      build_missing_enrollments
      build_day_ids
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
        target_enrollments << enrollment if !enrollment._destroy && enrollment.alive? && enrollment.program == @program
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
      found = false
      # step through without scopes, in case we have unapplied changes waiting
      child.enrollments.each do |enrollment|
        if enrollment.alive? && enrollment.program == @program && enrollment.plan_type == @plan_type
          found = true
          break;
        end
      end

      child.enrollments.build(program: @program, plan: @program.plans.by_plan_type(@plan_type).first) unless found
    end
  end

  def build_day_ids
    @children_day_ids = {}
    return if @plan_type.blank? || !@plan_type.full_day_contract?

    @account.children.each_with_index do |child, index|
      @children_day_ids[child.id] = {}
      child.enrollments.alive.by_program_and_plan_type(@program, @plan_type).each_with_index do |enrollment, index|
        if enrollment.monday
          @children_day_ids[child.id][:monday_id] = enrollment.plan_id
        end

        if enrollment.tuesday
          @children_day_ids[child.id][:tuesday_id] = enrollment.plan_id
        end

        if enrollment.wednesday
          @children_day_ids[child.id][:wednesday_id] = enrollment.plan_id
        end

        if enrollment.thursday
          @children_day_ids[child.id][:thursday_id] = enrollment.plan_id
        end

        if enrollment.friday
          @children_day_ids[child.id][:friday_id] = enrollment.plan_id
        end

        if enrollment.saturday
          @children_day_ids[child.id][:saturday_id] = enrollment.plan_id
        end

        if enrollment.sunday
          @children_day_ids[child.id][:sunday_id] = enrollment.plan_id
        end
      end
    end
  end

  def enrollment_params
    sanitized_params = params

    if sanitized_params["account"]["children_attributes"].present?
      sanitized_params["account"]["children_attributes"].each do |child_key, enrollment_attrs|

        if enrollment_attrs.present? && enrollment_attrs["enrollments_attributes"].present?
          enrollment_attrs["enrollments_attributes"].each do |enrollment_key, values|
            if sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"][enrollment_key]["_destroy"] == "1"
              sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"][enrollment_key]["_destroy"] = "true"
            end

            if sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"][enrollment_key]["plan_id"].blank?
              ap "plan id blank"
              sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"][enrollment_key]["_destroy"] = "true"
            end

            any_days = values.select{|key, value| ["monday", "tuesday", "wednesday", "thursday", "friday"].include?(key.to_s)}.values.reject{|v| ["0", "false"].include?(v)}.any?

            unless any_days
              if values["id"].present?
                sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"][enrollment_key]["_destroy"] = "true"
              else
                sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"].delete(enrollment_key)
              end
            end
          end
        end

        # We have a multi-day plan (TKK)
        if @plan_type.present? && @plan_type.full_day_contract?
          child = Child.find_by(id: enrollment_attrs['id'])
          next unless child.present?

          # Create the object for the specific child and set the id
          sanitized_params["account"] = {}
          sanitized_params["account"]["children_attributes"] = {}
          sanitized_params["account"]["children_attributes"][child_key] = {}
          sanitized_params["account"]["children_attributes"][child_key][:id] = enrollment_attrs['id']
          sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"] = {}

          day_dictionary = [
            "monday",
            "tuesday",
            "wednesday",
            "thursday",
            "friday"
          ]

          day_dictionary.each_with_index do |day_str, day_index|
            selected_plan_id = enrollment_attrs["#{day_str}_id"]
            existing_enrollment = child.enrollments.alive.by_program_and_plan_type(@program, @plan_type).where("enrollments.#{day_str} IS TRUE").first

            if selected_plan_id.blank? && existing_enrollment.blank?
              next
            end

            # set all days to 0 because multi-day enrollments will be added here
            sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"][day_index.to_s] = {
              :monday => "0",
              :tuesday => "0",
              :wednesday => "0",
              :thursday => "0",
              :friday => "0",
            }

            if selected_plan_id.present?
              sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"][day_index.to_s][day_dictionary[day_index]] = "1"
            else
              sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"][day_index.to_s]["_destroy"] = "true"
            end

            if existing_enrollment.present?
              sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"][day_index.to_s]['id']  = existing_enrollment.id.to_s
            end

            sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"][day_index.to_s]['child_id']  = enrollment_attrs['id']
            sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"][day_index.to_s]['plan_id']   = selected_plan_id
            sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"][day_index.to_s]['starts_at'] = enrollment_attrs['starts_at']
            sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"][day_index.to_s]['ends_at']   = enrollment_attrs['ends_at']
            sanitized_params["account"]["children_attributes"][child_key]["enrollments_attributes"][day_index.to_s]['location_id'] = enrollment_attrs["location_id"]
          end
        end
      end
    end

    sanitized_params.require(:account).permit(children_attributes: [:id, enrollments_attributes: [:id, :plan_id, :child_id, :location_id, :starts_at, :ends_at, :monday, :tuesday, :wednesday, :thursday, :friday, :_destroy, :dead]])
  end

  def account_params
    params.require(:account).permit(:payment_offset)
  end
end
