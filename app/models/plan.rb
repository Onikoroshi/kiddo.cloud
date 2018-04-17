class Plan < ApplicationRecord
  include ClassyEnum::ActiveRecord
  belongs_to :program

  has_many :enrollments
  has_many :children, through: :enrollments
  has_many :transactions, through: :enrollments

  money_column :price
  classy_enum_attr :plan_type

  validates :display_name, :short_code, :price, :days_per_week, presence: true
  validate :lock_enrolled_plans

  scope :by_plan_type, ->(plan_type) { where(plan_type: plan_type.to_s) }
  scope :by_program, ->(program) { program.present? ? where(program: program) : all }

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

  private

  def lock_enrolled_plans
    if (self.program_id_changed? && self.program_id_was.present?) || (self.plan_type_changed? && self.plan_type.present?)
      if enrollments.any? || transactions.any?
        errors.add(:base, "Children are already enrolled in this plan. Cannot change Program or Plan Type.")
      end
    end
  end
end
