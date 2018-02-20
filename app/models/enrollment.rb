class Enrollment < ApplicationRecord
  belongs_to :location
  belongs_to :child
  belongs_to :plan
  has_one :program, through: :plan

  validates :starts_at, :ends_at, presence: true
  validate :validate_dates

  scope :by_program, ->(program) { joins(plan: :program).where("programs.id = ?", program.present? ? program.id : nil) }

  def self.by_program_and_plan_type(program, plan_type)
    self.joins(:program).where("plans.plan_type = ? AND programs.id = ?", plan_type.to_s, program.id)
  end

  def plan_type
    plan.plan_type if plan.present?
  end

  def to_s
    case plan.plan_type.to_s
    when PlanType[:weekly].to_s
      "#{child.full_name} is enrolled in a Weekly #{plan.display_name} plan #{display_dates} at #{location.name}"
    when PlanType[:drop_in].to_s
      "#{child.full_name} is enrolled in a #{plan.display_name} on #{starts_at.stamp("Monday, Feb. 3rd, 2018")} at #{location.name}"
    else
      "#{child.full_name} is enrolled in the #{plan.display_name} plan on #{enrolled_days(humanize: true)} at #{location.name}."
    end
  end

  def display_dates
    if plan_type.drop_in?
      "on #{starts_at.stamp("Monday, Feb. 3rd, 2018")}"
    elsif plan_type.weekly?
      "for the week of #{starts_at.stamp("Monday, Feb. 3rd, 2018")} to #{ends_at.stamp("Monday, Feb. 3rd, 2018")}"
    else
      "from #{starts_at.stamp("Monday, Feb. 3rd, 2018")} to #{ends_at.stamp("Monday, Feb. 3rd, 2018")}"
    end
  end

  def enrolled_days(humanize = false)
    day_hash = {
      monday: monday,
      tuesday: tuesday,
      wednesday: wednesday,
      thursday: thursday,
      friday: friday,
      saturday: saturday,
      sunday: sunday,
    }

    selected = Array.new
    day_hash.each do |k,v|
      selected << k if v
    end

    if humanize
      value = selected.to_sentence.titleize
    else
      selected
    end
  end

  def enrolled_today?
    dictionary = {
      1 => "monday",
      2 => "tuesday",
      3 => "wednesday",
      4 => "thursday",
      5 => "friday",
      6 => "saturday",
      7 => "sunday",
    }

    today = Time.zone.now.wday
    send(dictionary[today])
  end

  private

  def validate_dates
    if plan_type.present? && plan_type.drop_in?
      ends_at = starts_at
    end

    if program.present?
      if (starts_at.present? && starts_at < program.starts_at) || (ends_at.present? && ends_at > program.ends_at)
        errors.add(:base, "#{program.name} only runs from #{program.starts_at} to #{program.ends_at}")
      end
    end
  end
end
