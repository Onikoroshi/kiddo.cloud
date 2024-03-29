class TimeDispute < ApplicationRecord
  belongs_to :location
  belongs_to :user

  validates :email, presence: true
  validates :first_name, :last_name, presence: true
  validates :message, presence: true
end
