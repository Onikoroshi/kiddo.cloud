class StaffLocation < ApplicationRecord
  belongs_to :staff
  belongs_to :location
end
