class Enrollment < ApplicationRecord
  belongs_to :location
  belongs_to :child
  belongs_to :plan
  has_one :program, through: :plan

  has_many :enrollment_transactions, dependent: :destroy
  has_many :transactions, through: :enrollment_transactions, source: :my_transaction

  has_many :enrollment_changes, dependent: :destroy

  before_validation :deduce_plan

  after_create :set_next_target_and_payment_date!

  validates :starts_at, :ends_at, presence: true
  validate :validate_dates

  # enrollments can be removed after being paid for, so we need to keep their information around
  scope :alive, -> { where.not(dead: true) }
  scope :dead, -> { where(dead: true) }

  scope :by_program, ->(program) { program.present? ? joins(:program).where("programs.id = ?", program.id) : none }
  scope :by_program_and_plan_type, ->(program, plan_type) { joins(:program).where("plans.plan_type = ? AND programs.id = ?", plan_type.to_s, program.id) }
  scope :by_program_and_location, ->(program, location) { (program.present? && location.present?) ? joins(:program).joins(:location).where("programs.id = ? AND locations.id = ?", program.id, location.id) : none }
  scope :by_child, ->(child) { child.present? ? where(child_id: child.id) : none }
  scope :by_location, ->(location) { location.present? ? where(location_id: location.id) : all }
  scope :active, -> { where("enrollments.ends_at >= ?", Time.zone.today).distinct }
  scope :paid, -> { where(paid: true) }
  scope :ever_paid, -> { joins(:transactions).where("transactions.paid IS TRUE").distinct }
  scope :unpaid, -> { where.not(paid: true) }
  scope :never_paid, -> { includes(:transactions).where("transactions.paid IS FALSE OR transactions.id IS NULL").references(:transactions).distinct }
  scope :with_changes, -> { joins(:enrollment_changes) }
  scope :without_changes, -> { includes(:enrollment_changes).where(enrollment_changes: {id: nil}) }
  scope :for_date, ->(date) { date.present? ? where("enrollments.starts_at <= ? AND enrollments.ends_at >= ?", date, date) : all }
  scope :recurring, -> { joins(:plan).where(plans: {plan_type: PlanType.recurring.map(&:to_s)}).distinct }

  def self.total_amount_due_today
    self.all.inject(Money.new(0)){ |sum, enrollment| sum + Money.new(enrollment.amount_due_today) }
  end

  # get a unique list of programs associated with a set of enrollments
  def self.programs
    Program.where(id: self.joins(:program).pluck("programs.id").uniq)
  end

  def self.active_blurbs(child)
    blurbs = []

    all_enrollments = self.alive.joins(:location, plan: :program).where("programs.ends_at >= ?", Time.zone.today)

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
            blurbs << "#{child.first_name} is enrolled in  #{num_enrolls} #{type_text.pluralize(num_enrolls)} at #{location.name} during #{program.name}"
          end
        end
      end
    end

    blurbs.flatten
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << [
        "Child Name",
        "Child Birthdate",
        "Primary Parent",
        "Email",
        "Phone",
        "Plan",
        "Day(s)",
        "Location"
      ]

      self.all.each do |enrollment|
        csv << [
          enrollment.child.full_name,
          enrollment.child.birthdate.stamp("2018-03-04"),
          enrollment.child.account.primary_parent.full_name,
          enrollment.child.account.user.email,
          enrollment.child.account.primary_parent.phone,
          enrollment.type_display,
          enrollment.service_dates,
          enrollment.location.name
        ]
      end
    end
  end

  def plan_type
    plan.plan_type if plan.present?
  end

  def alive?
    !dead?
  end

  def unpaid?
    !paid?
  end

  def kill!
    if unpaid?
      destroy
    else
      update_attribute(:dead, true)
    end
  end

  def resurrect!
    update_attribute(:dead, false)
  end

  def payment_plan_hash
    info = {}

    if plan_type.recurring?
      target_date = self.starts_at
      month_name = target_date.stamp("February, 2019")

      while target_date < self.ends_at
        info[month_name] = {} # let us pass on more complex information

        enrollment_transaction = transaction_covers_date(target_date)
        if enrollment_transaction.present?
          info[month_name]["message"] = "Paid #{enrollment_transaction.amount} on #{enrollment_transaction.created_at.to_date.stamp("Aug. 1st, 2019")} for the month of #{month_name}"
        else
          target_payment_date = target_date.beginning_of_month + child.account.payment_offset.days
          target_payment_past = target_payment_date < Time.zone.today
          target_payment_today = target_payment_date == Time.zone.today

          if target_payment_past || target_payment_today
            info[month_name]["overdue"] = true
          end

          info[month_name]["message"] = "#{plan.price_for_date(target_date)}#{" was" if target_payment_past} Due #{target_payment_today ? "Today" : "on #{target_payment_date.stamp("Aug. 1st, 2019")}"} for the month of #{month_name}"
        end

        target_date = target_date.end_of_month + 1.day
        month_name = target_date.stamp("February, 2019")
      end
    else
      info["One Time"] = {}
      if self.paid?
        info["One Time"]["message"] = "Paid #{last_paid_amount} on #{created_at.to_date.stamp("Aug. 1st, 2019")}"
      else
        info["One Time"]["message"] = "#{plan.price_for_date(target_date)} Due Today"
        info["One Time"]["overdue"] = true
      end
    end

    info
  end

  def set_next_target_and_payment_date(given_enrollment_transaction = nil)
    if plan_type.recurring?
      # update starts_at to make sure
      self.starts_at = [(self.starts_at || @program.starts_at).to_date, (created_at || Time.zone.today).to_date].max
      self.ends_at ||= @program.ends_at
      stop_date = nil

      latest_enrollment_transaction = given_enrollment_transaction || enrollment_transactions.paid.by_target_date.last
      stop_date = latest_enrollment_transaction.description_data["stop_date"] if latest_enrollment_transaction.present?

      if stop_date.present?
        target_date = stop_date.to_date.end_of_month + 1.day # move forward a month
      else # unless we don't have any yet - then do the first one
        target_date = self.starts_at # figured that out above
      end

      self.next_target_date = target_date
      self.next_payment_date = target_date + child.account.payment_offset.days

      self.paid = false if next_payment_date <= Time.zone.today
    else
      self.next_target_date ||= (created_at || Time.zone.today).to_date
      self.next_payment_date ||= (created_at || Time.zone.today).to_date
    end
  end

  def set_next_target_and_payment_date!(given_enrollment_transaction = nil)
    set_next_target_and_payment_date(given_enrollment_transaction)
    save
  end

  def deduce_current_service_dates
    unless plan_type.recurring?
      return starts_at, ends_at
    end

    start_date = next_target_date
    stop_date = start_date
    target_date = stop_date
    payment_date = next_payment_date
    while target_date <= program.ends_at && payment_date <= Time.zone.today
      stop_date = target_date
      target_date = target_date.end_of_month + 1.day
      payment_date = target_date + child.account.payment_offset.days
    end

    return start_date, stop_date
  end

  def amount_due_today
    unless plan_type.recurring?
      return paid? ? Money.new(0) : plan.price_for_date(next_target_date)
    end

    result = Money.new(0)

    target_date = next_target_date
    payment_date = next_payment_date
    while target_date <= program.ends_at && payment_date <= Time.zone.today
      result += plan.price_for_date(target_date)
      target_date = target_date.end_of_month + 1.day
      payment_date = target_date + child.account.payment_offset.days
    end

    result
  end

  def display_amount_due_today
    target_date = next_payment_date
    if target_date > Time.zone.today
      "#{Time.zone.today > self.starts_at ? "Next" : "First"} Payment on #{target_date.stamp("March 3rd, 2019")}"
    else
      amount_due_today.to_s
    end
  end

  def craft_enrollment_transactions(parent_transaction)
    unless plan_type.recurring?
      return if paid?
      EnrollmentTransaction.create(enrollment_id: self.id, my_transaction_id: parent_transaction.id, amount: plan.price_for_date(next_target_date), target_date: self.next_target_date, description_data: {"description" => self.to_short, "start_date" => self.starts_at, "stop_date" => self.ends_at})
    else
      target_date = next_target_date
      payment_date = next_payment_date

      # create a blank transaction for other changes to refer back to
      if payment_date >= Time.zone.today
        EnrollmentTransaction.create(enrollment_id: self.id, my_transaction_id: parent_transaction.id, amount: Money.new(0), target_date: self.starts_at, description_data: {"description" => self.to_short, "start_date" => self.starts_at, "stop_date" => self.ends_at})
      end

      while target_date <= program.ends_at && payment_date <= Time.zone.today
        stop_date = target_date.end_of_month
        EnrollmentTransaction.create(enrollment_id: self.id, my_transaction_id: parent_transaction.id, amount: plan.price_for_date(target_date), target_date: target_date, description_data: {"description" => self.to_short, "start_date" => target_date, "stop_date" => stop_date})
        target_date = stop_date + 1.day
        payment_date = target_date + child.account.payment_offset.days
      end
    end

    self.update_attribute(:paid, true)
    self.set_next_target_and_payment_date!
  end

  def transaction_for_target_date(given_date)
    enrollment_transactions.paid.where(target_date: given_date).reverse_chronological.first
  end

  def transaction_covers_date(given_date)
    enrollment_transactions.paid.where("description_data->'start_date' <= ? AND description_data->'stop_date' >= ?", given_date, given_date).reverse_chronological.first
  end

  def last_transaction
    transactions.paid.reverse_chronological.first
  end

  def last_payment_target_date
    enrollment_transaction = enrollment_transactions.paid.by_target_date.last
    (enrollment_transaction.present? && enrollment_transaction.target_date.present?) ? enrollment_transaction.target_date : nil
  end

  def last_payment_date
    transaction = transactions.paid.reverse_chronological.first
    transaction.present? ? transaction.created_at.to_date : nil
  end

  def last_paid_amount
    enrollment_transaction = enrollment_transactions.paid.reverse_chronological.first
    enrollment_transaction.present? ? enrollment_transaction.amount : Money.new(0)
  end

  def to_s
    case plan.plan_type.to_s
    when PlanType[:weekly].to_s
      "#{child.full_name} is enrolled in a #{to_short}"
    when PlanType[:drop_in].to_s
      "#{child.full_name} is enrolled in a #{to_short}"
    else
      "#{child.full_name} is enrolled in the #{to_short}"
    end
  end

  def to_short
    case plan.plan_type.to_s
    when PlanType[:weekly].to_s
      "Weekly #{plan.display_name} plan #{display_dates} at #{location.name}"
    when PlanType[:drop_in].to_s
      "Drop-In on #{starts_at.stamp("Monday, Feb. 3rd, 2018")} at #{location.name}"
    else
      "#{"#{plan.display_name} " unless plan.deduceable?}#{plan.plan_type.text} plan on #{enrolled_days(humanize: true)} from #{service_dates} at #{location.name}."
    end
  end

  def description
    "#{child.full_name} - #{to_short}"
  end

  def type_display
    "#{plan_type.text}#{" #{plan.display_name}" unless plan.deduceable?}"
  end

  def service_dates
    if plan_type.drop_in?
      starts_at.stamp("Monday, Feb. 3rd, 2018")
    elsif plan_type.weekly?
      DateTool.display_week(starts_at, ends_at)
    else
      DateTool.display_range(starts_at, ends_at)
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

  def enrolled_days(humanize = false)
    selected = Array.new
    day_hash.each do |k,v|
      selected << k if v
    end

    if humanize
      if plan_type.recurring?
        selected.map{|d| d.to_s.capitalize.pluralize}.to_sentence
      else
        selected.map{|d| d.to_s.capitalize}.to_sentence
      end
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
      0 => "sunday",
    }

    today = Time.zone.now.wday
    send(dictionary[today])
  end

  private

  def deduce_plan
    return if self.plan.blank? || self.plan.choosable? # don't worry about restrictions if the plan is a manual choice

    target_days = enrolled_days
    num_days = target_days.count

    return if num_days == 0

    # leave the current plan if it is "allowed"
    # -1 plan days_per_week means that they want to allow any number of days.
    return if [-1, num_days].include?(self.plan.days_per_week.to_i) && (target_days & self.plan.allowed_days).any?

    target_program = plan.program
    target_plan_type = plan.plan_type
    possible_plans = program.plans.by_plan_type(target_plan_type)

    success = false

    possible_plans.find_each do |possible_plan|
      if [-1, num_days].include?(possible_plan.days_per_week.to_i) && (target_days & possible_plan.allowed_days).any?
        self.plan_id = possible_plan.id
        success = true
        break
      end
    end

    unless success
      errors.add(:base, "No payment plans cover the days selected for #{self.child.full_name}. Try a different combination of days.")
    end
  end

  def validate_dates
    if plan_type.present? && plan_type.drop_in?
      ends_at = starts_at
      errors.add(:base, "#{child.first_name} cannot attend on #{starts_at.stamp("Mar. 3rd, 2018")} as we are closed for Independance Day") if starts_at.month == 7 && starts_at.day == 4
    end

    if program.present?
      if (starts_at.present? && starts_at < program.starts_at) || (ends_at.present? && ends_at > program.ends_at)
        errors.add(:base, "#{child.first_name} cannot attend on #{starts_at.stamp("Mar. 3rd, 2018")} as #{program.name} only runs from #{program.starts_at} to #{program.ends_at}")
      end
    end

    if starts_at.present? && ends_at.present? && ([0, 6] & (starts_at.wday..ends_at.wday).to_a).any?
      errors.add(:base, "#{child.first_name} cannot attend on #{starts_at.stamp("Mar. 3rd, 2018")} because we are only in session on weekdays")
    end
  end
end
