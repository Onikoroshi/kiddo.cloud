class Program < ApplicationRecord
  include ClassyEnum::ActiveRecord

  belongs_to :center
  belongs_to :program_group

  has_many :plans, dependent: :destroy
  has_many :enrollments, through: :plans
  has_many :children, through: :enrollments
  has_many :transactions, through: :enrollments
  has_many :drop_ins
  has_many :announcements, dependent: :destroy
  has_many :holidays, dependent: :destroy

  has_many :program_locations, dependent: :destroy
  has_many :locations, through: :program_locations

  accepts_nested_attributes_for :holidays, allow_destroy: true

  money_column :registration_fee
  money_column :change_fee

  classy_enum_attr :program_type

  before_add_for_locations << ->(method, owner, change) { owner.send(:on_add_location, change) }
  before_remove_for_locations << ->(method, owner, change) { owner.send(:on_remove_location, change) }

  after_initialize :initialize_location_changes

  validates :name, :starts_at, :ends_at, :registration_opens, :registration_closes, :registration_fee, :change_fee, presence: true

  validate :validate_changed_location_free

  after_save :sync_enrollments

  scope :require_payment_information, -> { where(waive_payment_information: false) }
  scope :waive_payment_information, -> { where(waive_payment_information: true) }

  scope :order_by_priority, -> { order("priority ASC") }
  scope :descending_by_start_date, -> { order("starts_at DESC") }
  scope :descending_by_updated, -> { order("updated_at DESC") }

  scope :open_for_registration, -> { where("registration_opens <= ? AND registration_closes >= ?", Time.zone.today, Time.zone.today) }
  scope :in_session, -> { where("starts_at <= ? AND ends_at >= ?", Time.zone.today, Time.zone.today) }
  scope :active, -> { where("ends_at >= ?", Time.zone.today) }

  scope :for_fall, -> { where(program_type: ProgramType[:fall].to_s) }
  scope :for_summer, -> { where(program_type: ProgramType[:summer].to_s) }

  scope :with_program_group, -> { includes(:program_group).references(:program_groups).where("program_groups.id IS NOT NULL") }
  scope :without_program_group, -> { includes(:program_group).references(:program_groups).where("program_groups.id IS NULL") }
  scope :by_program_group, ->(program_group) { program_group.present? ? where(program_group: program_group) : none }

  # get a unique list of program groups associated with a set of enrollments
  def self.program_groups
    ProgramGroup.where(id: self.pluck("program_group_id").reject(&:blank?).uniq)
  end

  def custom_request_plan
    target_plan = plans.by_plan_type(PlanType[:custom_request].to_s).first

    if target_plan.blank?
      target_plan = Plan.create!(program_id: self.id, plan_type: PlanType[:custom_request].to_s, display_name: "Custom Requests", price: 0.0, days_per_week: 5, enabled: true)
    end

    target_plan
  end

  def available_locations
    Location.where(id: program_locations.available.pluck(:location_id))
  end

  def plan_types
    plans.select{|plan| !custom_requests? || !plan.plan_type.custom_request?}.map{|plan| plan.plan_type}.uniq{|plan| plan.to_s}
  end

  def short_name
    name.gsub("Davis Kids Klub ", "")
  end

  def to_s
    short_name
  end

  def program_group_name
    program_group.present? ? program_group.title : ""
  end

  def can_destroy?
    return false if plans.any?
    return false if enrollments.any?
    return false if transactions.any?
    return false if locations.any?

    true
  end

  def locations_changed?
    @location_changes[:removed].present? or @location_changes[:added].present?
  end

  def grade_allowed?(given_grade)
    allowed_grades.reject(&:blank?).map(&:to_s).include?(given_grade.to_s)
  end

  private

  def on_add_location(location)
    initialize_location_changes_safe
    @location_changes[:added] << location.id
  end

  def on_remove_location(location)
    initialize_location_changes_safe
    @location_changes[:removed] << location.id
  end

  def initialize_location_changes
    @location_changes = {added: [], removed: []}
  end

  def initialize_location_changes_safe
    @location_changes = {added: [], removed: []} if @location_changes.nil?
  end

  def validate_changed_location_free
    return unless self.locations_changed?

    unless @location_changes[:added].nil?
    end

    unless @location_changes[:removed].nil?
      @location_changes[:removed].each do |location_id|
        location = Location.find_by(id: location_id)
        next unless location.present?

        errors.add(:base, "#{location.name} already has people attending and cannot be removed.") if Enrollment.active.by_program_and_location(self, location).any?
      end
    end
  end

  def sync_enrollments
    if starts_at_changed? || ends_at_changed? || earliest_payment_offset_changed? || latest_payment_offset_changed?
      enrollments.recurring.find_each do |enrollment|
        if starts_at_changed?
          enrollment.update_attribute(:starts_at, [self.starts_at, enrollment.created_at.to_date].max)
        end

        # only change the enrollment stop date if they were in for the full duration (end at the same date as the program) *or* the program is now ending earlier than the enrollment would have
        if ends_at_changed? && ((enrollment.ends_at == ends_at_was) || (self.ends_at < enrollment.ends_at))
          enrollment.update_attribute(:ends_at, self.ends_at)
        end

        if starts_at_changed? || ends_at_changed?
          enrollment.set_next_target_and_payment_date!

          enrollment.enrollment_transactions.find_each do |et|
            data_hash = et.description_data
            # keep the descriptions updated
            data_hash.merge!({"description" => et.enrollment.to_short})
            if et.placeholder? # only change the date if it's the initial placeholder
              data_hash.merge!({"stop_date" => [et.enrollment.starts_at - 1.day, data_hash["start_date"].to_date].max})
            end
            et.update_attributes(description_data: data_hash)
          end
        end

        if earliest_payment_offset_changed? && enrollment.child.account.payment_offset < earliest_payment_offset
          enrollment.child.account.update_attribute(:payment_offset, self.earliest_payment_offset)
        end

        if latest_payment_offset_changed? && enrollment.child.account.payment_offset > latest_payment_offset
          enrollment.child.account.update_attribute(:payment_offset, self.latest_payment_offset)
        end

        enrollment.set_next_target_and_payment_date!
      end
    end
  end
end
