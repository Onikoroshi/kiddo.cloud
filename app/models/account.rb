class Account < ApplicationRecord
  belongs_to :user
  belongs_to :center

  has_many :parents, dependent: :destroy
  has_one :primary_parent, ->(p) { where primary: true }, class_name: "Parent"
  has_one :secondary_parent, ->(p) { where secondary: true }, class_name: "Parent"
  has_one :subscription

  has_many :children
  has_many :emergency_contacts, dependent: :destroy

  delegate :name, to: :center, prefix: :center

  accepts_nested_attributes_for :children, allow_destroy: true

  def primary_email
    user.email
  end

  def record_step(step)
    update_attributes(last_registration_step_completed: step)
  end

  def signup_complete?
    self.signup_complete
  end

  def mark_signup_complete!
    self.update_attributes(signup_complete: true)
  end

  def finalize_signup
    mark_signup_complete!
    TransactionalMailer.welcome_customer(self).deliver_now
    TransactionalMailer.waivers_and_agreements(self).deliver_now if mail_agreements
  end

  def customer?
    gateway_customer_id.present?
  end

  def create_default_child_attendance_selections
    children.each do |child|
      AttendanceSelection.where(child_id: child.id).first_or_create!
    end
  end

  def summarize_enrollments(program)
    result = Array.new
    program.plans.each do |p|
      children.each do |c|
        result << c.enrollments.where(plan: p).first.to_s
      end
    end
    result.flatten.reject(&:empty?)
  end

end




