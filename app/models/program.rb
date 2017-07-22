class Program < ApplicationRecord
  belongs_to :center
  has_many :program_plans

  has_many :attendance_plans
  has_many :children, through: :attendance_plans
end
