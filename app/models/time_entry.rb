class TimeEntry < ApplicationRecord
  belongs_to :location
  belongs_to :time_recordable, polymorphic: :true

end
