class Staff < ApplicationRecord
  belongs_to :user
  has_many :time_entries, as: :time_recordable
end
