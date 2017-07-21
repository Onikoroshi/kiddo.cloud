class Account < ApplicationRecord
  belongs_to :user
  belongs_to :center

  has_many :parents, dependent: :destroy
  has_one :primary_parent, ->(p) { where primary: true }, class_name: "Parent"
  has_one :secondary_parent, ->(p) { where secondary: true }, class_name: "Parent"

  has_many :children
  has_many :emergency_contacts, dependent: :destroy

  delegate :name, to: :center, prefix: :center

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

end




