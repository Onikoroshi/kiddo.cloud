class Staff < ApplicationRecord
  belongs_to :user
  has_many :time_entries, as: :time_recordable

  has_many :staff_locations
  has_many :locations, through: :staff_locations

  delegate :full_name, to: :user

  def last_time_entry
    self.time_entries.last
  end

  def on_clock?
    return false unless last_time_entry.present?
    last_time_entry.record_type == "entry"
  end
end
