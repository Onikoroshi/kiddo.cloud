class Plan < ApplicationRecord
  include ClassyEnum::ActiveRecord
  belongs_to :program

  has_many :enrollments
  has_many :children, through: :enrollments
  has_many :transactions, through: :enrollments

  money_column :price
  classy_enum_attr :plan_type

  scope :by_plan_type, ->(plan_type) { where(plan_type: plan_type.to_s) }

  def self.select_options
    all.map{|plan| [plan.display_name, plan.id]}
  end

  def full_display_name
    "#{plan_type.text} #{display_name}"
  end

  def display_days_per_week
    if days_per_week == 0
      "Any"
    elsif days_per_week == 5
      "All"
    else
      days_per_week.to_s
    end
  end

  def can_destroy?
    return false if enrollments.any?
    return false if transactions.any?

    true
  end
end
