class Account < ApplicationRecord
  attr_accessor :validate_location
  belongs_to :user
  belongs_to :center

  # belongs_to :location # not used anymore
  belongs_to :program # only used during the enrollment process

  has_many :parents, dependent: :destroy
  has_one :primary_parent, -> { where primary: true }, class_name: "Parent"
  has_one :secondary_parent, -> { where secondary: true }, class_name: "Parent"
  has_one :subscription, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :late_checkin_notifications, dependent: :destroy

  has_many :children, dependent: :destroy
  has_many :enrollments, through: :children
  has_many :enrollment_changes, through: :enrollments
  has_many :emergency_contacts, dependent: :destroy

  has_many :drop_ins

  delegate :name, to: :center, prefix: :center

  accepts_nested_attributes_for :children, allow_destroy: true

  before_validation :force_send_agreements

  validates :location_id, presence: true, if: :validate_location?

  after_save :update_enrollment_payment_dates

  scope :by_program, ->(given_program) { given_program.present? ? joins(enrollments: :program).where("enrollments.dead IS FALSE AND programs.id = ?", given_program.id).distinct : all }
  scope :by_location, ->(given_location) { given_location.present? ? joins(:enrollments).where("enrollments.dead IS FALSE AND enrollments.location_id = ?", given_location.id).distinct : all }

  def self.to_csv
    CSV.generate do |csv|
      csv << [
        "Child Last Name",
        "Child First Name",
        "Birthdate",
        "Primary Parent",
        "Email",
        "Phone",
        "Secondary Contact",
        "Phone",
        "Emergency Contact",
        "Phone",
        "Medical",
        "Phone",
        "Dental",
        "Phone",
        "Insurance",
        "Policy Number",
        "Notes",
      ]
      self.all.each do |account|
        primary_parent = account.primary_parent
        secondary_parent = account.secondary_parent
        emergency_contact = account.emergency_contacts.first

        account_info = primary_parent.present? ? [primary_parent.full_name] : [""]

        account_info << account.user.email

        account_info << (primary_parent.present? ? primary_parent.phone : "")

        account_info += secondary_parent.present? ? [secondary_parent.full_name, secondary_parent.phone] : ["", ""]

        account_info += emergency_contact.present? ? [emergency_contact.full_name, emergency_contact.phone] : ["", ""]

        account_info += [
          account.family_physician,
          account.physician_phone,
          account.family_dentist,
          account.dentist_phone,
          account.insurance_company,
          account.insurance_policy_number,
        ]

        account.children.each do |child|
          child_info = [child.last_name, child.first_name, child.birthdate.stamp("5/13/2011")]
          child_info += account_info

          if child.care_items.active.any?
            notes = child.care_items.active.map{|item| "#{item.name}: #{item.explanation}"}.join("\n")
            unless child.additional_info.blank?
              notes += "\n#{child.additional_info}"
            end

            child_info << notes
          else
            child_info << ""
          end

          csv << child_info
        end
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
    enrolled_programs = enrollments.alive.active.programs
    TransactionalMailer.welcome_summer_customer(self).deliver_now if enrolled_programs.for_summer.any?
    TransactionalMailer.welcome_fall_customer(self).deliver_now if enrolled_programs.for_fall.any?
    TransactionalMailer.waivers_and_agreements(self).deliver_now # if mail_agreements # send them automatically
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

  def announcements
    enrolled_programs = enrollments.alive.active.programs

    hash = {}

    enrolled_programs.each do |program|
      program.announcements.find_each do |announcement|
        hash[program.name] = [] if hash[program.name].nil?
        hash[program.name] << announcement.message
      end
    end

    hash
  end

  private

  def force_send_agreements
    self.mail_agreements = true
  end

  def update_enrollment_payment_dates
    if payment_offset_changed?
      consider_enrollments = enrollments.alive.active.recurring
      consider_enrollments.map{|e| e.set_next_target_and_payment_date!}
    end
  end
end
