class TimeEntryType < ClassyEnum::Base
end

class TimeEntryType::Entry < TimeEntryType
  def text
    "Clock In"
  end
end

class TimeEntryType::Exit < TimeEntryType
  def text
    "Clock Out"
  end
end
