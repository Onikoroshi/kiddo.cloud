class Account < ApplicationRecord
  belongs_to :user
  belongs_to :center
  has_many :parents
  has_many :children
  has_many :emergency_contacts, dependent: :destroy

  def primary_parent
    parents.where(primary: true).first
  end

  def record_step(step)
    update_attributes(last_registration_step_completed: step)
  end

  def signup_complete?
    self.signup_complete
  end

end
