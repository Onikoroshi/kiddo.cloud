class TimeEntry < ApplicationRecord
  belongs_to :location
  belongs_to :time_recordable, polymorphic: true

  def checked_in?
    self.record_type == "entry"
  end

  def checked_out?
    self.record_type == "exit"
  end

  def parent
    time_recordable
  end

  def recordable_name
    parent.full_name
  end

end
