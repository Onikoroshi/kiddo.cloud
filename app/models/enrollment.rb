class Enrollment < ApplicationRecord
  belongs_to :child
  belongs_to :plan
end
