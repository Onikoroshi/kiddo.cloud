class Plan < ApplicationRecord
  include ClassyEnum::ActiveRecord
  belongs_to :program

  has_many :enrollments
  has_many :children, through: :enrollments

  has_many :transactions

  money_column :price
  classy_enum_attr :plan_type

  scope :by_plan_type, ->(plan_type) { where(plan_type: plan_type.to_s) }

  def self.select_options
    all.map{|plan| [plan.display_name, plan.id]}
  end
end
