class Account < ApplicationRecord
  attr_accessor :validate_location
  belongs_to :user
  belongs_to :center

  has_many :parents, dependent: :destroy
  has_one :primary_parent, -> { where primary: true }, class_name: "Parent"
  has_one :secondary_parent, -> { where secondary: true }, class_name: "Parent"
  has_one :subscription, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :late_checkin_notifications, dependent: :destroy

  validates :location_id, presence: true, if: :validate_location?

  belongs_to :location
  belongs_to :program # only used during the enrollment process

  has_many :children, dependent: :destroy
  has_many :enrollments, through: :children
  has_many :enrollment_changes, through: :enrollments
  has_many :emergency_contacts, dependent: :destroy

  has_many :drop_ins

  delegate :name, to: :center, prefix: :center

  accepts_nested_attributes_for :children, allow_destroy: true

  after_save :update_enrollment_payment_dates

  scope :by_program, ->(given_program) { given_program.present? ? joins(enrollments: :program).where("programs.id = ?", given_program.id).distinct : all }
  scope :by_location, ->(given_location) { given_location.present? ? joins(:enrollments).where("enrollments.location_id = ?", given_location.id).distinct : all }

  def self.to_csv
    CSV.generate do |csv|
      csv << ["Primary Parent", "Email", "Phone", "Children", "Location(s)"]
      self.all.each do |account|
        csv << [account.primary_parent.full_name, account.user.email, account.primary_parent.phone, account.children.map(&:full_name).to_sentence, account.active_locations.map(&:name).to_sentence]
      end
    end
  end

  def primary_email
    user.email
  end

  def record_step(step)
    update_attributes(last_registration_step_completed: step)
  end

  def signup_complete?
    signup_complete
  end

  def mark_signup_complete!
    update_attributes(signup_complete: true)
  end

  def finalize_signup
    legacy_user = LegacyUser.find_by(email: user.email)
    legacy_user.update_attributes(completed_signed_up: true) if legacy_user.present?

    mark_signup_complete!
    TransactionalMailer.welcome_customer(self).deliver_now
    TransactionalMailer.waivers_and_agreements(self).deliver_now if mail_agreements
  end

  def customer?
    gateway_customer_id.present?
  end

  def pending_enrollment_changes?
    enrollments.alive.unpaid.count > 0 || enrollment_changes.pending.count > 0
  end

  def create_default_child_attendance_selections
    children.each do |child|
      AttendanceSelection.where(child_id: child.id).first_or_create!
    end
  end

  def destroy_attendance_selections
    children.map { |c| c.attendance_selection.destroy if c.attendance_selection.present? }
  end

  def summarize_enrollments(program)
    result = Array.new
    program.plans.each do |p|
      children.each do |c|
        result << c.enrollments.alive.where(plan: p).first.to_s
      end
    end
    result.flatten.reject(&:blank?)
  end

  def active_locations
    location_ids = enrollments.alive.active.pluck(:location_id).uniq
    Location.where(id: location_ids)
  end

  def children_enrolled?(program)
    return false unless children.any?
    children.includes(:enrollments).map { |c| c.enrolled?(program) }.all?
  end

  def mark_paid!
    children.each do |c|
      c.enrollments.alive.each do |enrollment|
        enrollment.update_attributes(paid: true)
      end
    end
  end

  def validate_location?
    validate_location.present? && validate_location == true
  end

  private

  def update_enrollment_payment_dates
    if payment_offset_changed?
      consider_enrollments = enrollments.alive.active.recurring
      consider_enrollments.map{|e| e.set_next_target_and_payment_date!}
    end
  end
end
