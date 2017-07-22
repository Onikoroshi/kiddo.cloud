class AttendancePlan < ApplicationRecord
  belongs_to :child
  belongs_to :program
end
