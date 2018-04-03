class Enrollment < ApplicationRecord
  belongs_to :location
  belongs_to :child
  belongs_to :plan
  has_one :program, through: :plan

  has_many :enrollment_transactions, dependent: :destroy
  has_many :transactions, through: :enrollment_transactions, source: :my_transaction

  validates :starts_at, :ends_at, presence: true
  validate :validate_dates

  scope :by_program, ->(program) { joins(plan: :program).where("programs.id = ?", program.present? ? program.id : nil) }
  scope :by_program_and_plan_type, ->(program, plan_type) { joins(:program).where("plans.plan_type = ? AND programs.id = ?", plan_type.to_s, program.id) }
  scope :paid, -> { where(paid: true) }
  scope :unpaid, -> { where.not(paid: true) }

  # get a unique list of programs associated with a set of enrollments
  def self.programs
    Program.where(id: self.joins(plan: :program).pluck("programs.id").uniq)
  end

  def self.active
    self.joins(:program).where("programs.ends_at >= ?", Time.zone.today).distinct
  end

  def self.active_blurbs(child)
    blurbs = []

    all_enrollments = self.joins(:location, plan: :program).where("programs.ends_at >= ?", Time.zone.today)

    program_ids = all_enrollments.pluck("programs.id").uniq
    Program.where(id: program_ids).find_each do |program|
      program_enrollments = all_enrollments.where("programs.id = ?", program.id)

      location_ids = program_enrollments.pluck("locations.id").uniq
      Location.where(id: location_ids).find_each do |location|
        location_enrollments = program_enrollments.where("locations.id = ?", location.id)

        plan_types = location_enrollments.pluck("plans.plan_type").uniq.sort
        plan_types.each do |plan_type|
          plan_type_enrollments = location_enrollments.where("plans.plan_type = ?", plan_type)
          num_enrolls = plan_type_enrollments.count

          case plan_type.to_s
          when PlanType[:weekly].to_s
            blurbs << "#{child.first_name} is attending  #{num_enrolls} #{"Week".pluralize(num_enrolls)} at #{location.name} during #{program.short_name}"
          when PlanType[:drop_in].to_s
            blurbs << "#{child.first_name} has #{num_enrolls} #{"Drop-In".pluralize(num_enrolls)} at #{location.name} during #{program.short_name}"
          else
            type_obj = PlanType[plan_type]
            type_text = type_obj.present? ? type_obj.text : plan_type.humanize
            blurbs << "#{child.first_name} is enrolled in  #{num_enrolls} #{type_text.pluralise(num_enrolls)} at #{location.short_name} during #{program.name}"
          end
        end
      end
    end

    blurbs.flatten
  end

  def plan_type
    plan.plan_type if plan.present?
  end

  def unpaid?
    !paid?
  end

  def to_s
    case plan.plan_type.to_s
    when PlanType[:weekly].to_s
      "#{child.full_name} is enrolled in a Weekly #{plan.display_name} plan #{display_dates} at #{location.name}"
    when PlanType[:drop_in].to_s
      "#{child.full_name} is enrolled in a #{plan.display_name} Drop-In on #{starts_at.stamp("Monday, Feb. 3rd, 2018")} at #{location.name}"
    else
      "#{child.full_name} is enrolled in the #{plan.display_name} plan on #{enrolled_days(humanize: true)} at #{location.name}."
    end
  end

  def to_short
    case plan.plan_type.to_s
    when PlanType[:weekly].to_s
      "Weekly #{plan.display_name} plan #{display_dates} at #{location.name}"
    when PlanType[:drop_in].to_s
      "#{plan.display_name} Drop-In on #{starts_at.stamp("Monday, Feb. 3rd, 2018")} at #{location.name}"
    else
      "#{plan.display_name} plan on #{enrolled_days(humanize: true)} at #{location.name}."
    end
  end

  def type_display
    "#{plan_type.text} #{plan.display_name}"
  end

  def service_dates
    if plan_type.drop_in?
      starts_at.stamp("Monday, Feb. 3rd, 2018")
    elsif plan_type.weekly?
      "#{starts_at.stamp("Monday, Feb. 3rd, 2018")} to #{ends_at.stamp("Monday, Feb. 3rd, 2018")}"
    else
      "#{starts_at.stamp("Monday, Feb. 3rd, 2018")} to #{ends_at.stamp("Monday, Feb. 3rd, 2018")}"
    end
  end

  def display_dates
    if plan_type.drop_in?
      "on #{service_dates}"
    elsif plan_type.weekly?
      "for the week of #{service_dates}"
    else
      "from #{service_dates}"
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
      errors.add(:base, "closed on July 4th") if starts_at == Time.zone.parse("2018-07-04").to_date
    end

    if program.present?
      if (starts_at.present? && starts_at < program.starts_at) || (ends_at.present? && ends_at > program.ends_at)
        errors.add(:base, "#{program.name} only runs from #{program.starts_at} to #{program.ends_at}")
      end
    end

    if starts_at.present? && ends_at.present? && ([5, 6] & (starts_at.wday..ends_at.wday).to_a).any?
      errors.add(:base, "weekdays only")
    end
  end
end
