class TimeEntry < ApplicationRecord
  belongs_to :location
  belongs_to :time_recordable, polymorphic: true

  scope :entries_in_range, -> (range) do
    # start = (time - 5.minutes).strftime("%T")
    # ending = (time + 5.minutes).strftime("%T")
    start_time = range.first
    end_time = range.last
    where(record_type: "entry")
      .where("time >= ? and time <= ?", start_time, end_time)
  end

  def checked_in?
    record_type == "entry"
  end

  def checked_out?
    record_type == "exit"
  end

  def parent
    time_recordable
  end

  def recordable_name
    parent.full_name
  end
end
