class TimeEntry < ApplicationRecord
  include ClassyEnum::ActiveRecord

  belongs_to :location
  belongs_to :time_recordable, polymorphic: true

  classy_enum_attr :record_type, enum: "TimeEntryType"

  scope :entries_in_range, -> (range) do
    start_time = range.first
    end_time = range.last
    where(record_type: TimeEntryType[:entry])
      .where("time >= ? and time <= ?", start_time, end_time)
  end

  def checked_in?
    record_type.present? && record_type.entry?
  end

  def checked_out?
    record_type.blank? || record_type.exit?
  end

  def parent
    time_recordable
  end

  def recordable_name
    parent.full_name
  end
end
