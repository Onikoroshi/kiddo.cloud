class EmergencyContact < ApplicationRecord
  belongs_to :account

  def full_name
    "#{first_name} #{last_name}"
  end
end
