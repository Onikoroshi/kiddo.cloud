class Program < ApplicationRecord
  belongs_to :center

  has_many :program_plans, dependent: :destroy
  has_many :children, through: :program_plans
end
