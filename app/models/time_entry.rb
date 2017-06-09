class TimeEntry < ApplicationRecord
  belongs_to :time_recordable, polymorphic: :true
end
