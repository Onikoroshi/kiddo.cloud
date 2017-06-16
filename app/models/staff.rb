class Staff < ApplicationRecord
  belongs_to :user
  has_many :time_entries, as: :time_recordable

  delegate :full_name, to: :user
end
