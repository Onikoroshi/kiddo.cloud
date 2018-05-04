class Plan < ApplicationRecord
  include ClassyEnum::ActiveRecord
  belongs_to :program

  has_many :enrollments
  has_many :children, through: :enrollments
  has_many :transactions, through: :enrollments

  has_many :discounts

  money_column :price
  classy_enum_attr :plan_type

  validates :display_name, :price, :days_per_week, presence: true
  validate :lock_enrolled_plans

  accepts_nested_attributes_for :discounts, allow_destroy: true

  scope :by_plan_type, ->(plan_type) { where(plan_type: plan_type.to_s) }
  scope :by_program, ->(program) { program.present? ? where(program: program) : all }
  scope :deduceable, -> { where(deduce: true) }
  scope :choosable, -> { where(deduce: false) }

  def self.select_options
    all.map{|plan| [plan.display_name, plan.id]}
  end

  def full_display_name
    "#{plan_type.text} #{display_name}"
  end

  def price_for_date(given_date)
    net_price = self.price

    net_price -= discounts.by_month(given_date).inject(Money.new(0)){ |sum, discount| sum + discount.amount }

    net_price
  end

  def display_days_per_week
    if days_per_week < 0
      "Any"
    elsif days_per_week == 0
      "None"
    elsif days_per_week == 5
      "All"
    else
      days_per_week.to_s
    end
  end

  def day_hash
    {
      monday: monday,
      tuesday: tuesday,
      wednesday: wednesday,
      thursday: thursday,
      friday: friday,
      saturday: saturday,
      sunday: sunday
    }
  end

  def allowed_days(humanize = false)
    selected = Array.new
    day_hash.each do |k,v|
      selected << k if v
    end

    if humanize
      selected.any? ? selected.map{|day_key| day_key.to_s[0...(day_key.to_s.starts_with?("t") ? 2 : 1)].capitalize}.join(", ") : "None"
    else
      selected
    end
  end

  def can_destroy?
    return false if enrollments.any?
    return false if transactions.any?

    true
  end

  def deduceable?
    deduce?
  end

  def choosable?
    !deduceable?
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
