class Enrollment < ApplicationRecord
  belongs_to :location
  belongs_to :child
  has_one :account, through: :child
  belongs_to :plan
  has_one :program, through: :plan

  has_many :enrollment_transactions, dependent: :destroy
  has_many :transactions, through: :enrollment_transactions, source: :my_transaction

  has_many :enrollment_changes, dependent: :destroy

  before_validation :deduce_plan

  after_create :set_next_target_and_payment_date!

  validates :starts_at, :ends_at, presence: true
  validate :validate_dates

  DAY_DICTIONARY = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]

  # enrollments can be removed after being paid for, so we need to keep their information around
  scope :alive, -> { where.not(dead: true) }
  scope :dead, -> { where(dead: true) }

  scope :by_program, ->(program) { program.present? ? joins(:program).where("programs.id = ?", program.id) : all }
  scope :by_plan_type, ->(plan_type) { plan_type.present? ? joins(:plan).where("plans.plan_type = ?", plan_type.to_s) : all }
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
  scope :for_date, ->(date) { date.present? ? where("enrollments.starts_at <= ? AND enrollments.ends_at >= ? AND enrollments.#{DAY_DICTIONARY[date.wday]} IS TRUE", date, date) : all }
  scope :recurring, -> { joins(:plan).where(plans: {plan_type: PlanType.recurring.map(&:to_s)}).distinct }
  scope :one_time, -> { joins(:plan).where(plans: {plan_type: PlanType.one_time.map(&:to_s)}).distinct }

  scope :due_by_today, -> { where("enrollments.next_payment_date <= ?", Time.zone.today) }

  def self.by_program_on_date(program, date)
    if program.present?
      return self.none if program.holidays.pluck(:holidate).include?(date)

      self.by_program(program).for_date(date)
    else
      self.for_date(date)
    end
  end

  def self.total_amount_due_today
    self.all.inject(Money.new(0)){ |sum, enrollment| sum + Money.new(enrollment.amount_due_today) }
  end

  def self.next_payment_date
    self.reorder("next_payment_date ASC").first.next_payment_date
  end

  # get a unique list of programs associated with a set of enrollments
  def self.programs
    Program.where(id: self.joins(:program).pluck("programs.id").uniq)
  end

  # get a unique list of locations associated with a set of enrollments
  def self.locations
    Location.where(id: self.joins(:location).pluck("locations.id").uniq)
  end

  # get a unique list of programs associated with a set of enrollments
  def self.plan_types
    self.joins(:plan).pluck("plans.plan_type").uniq
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
        "Child Last Name",
        "Child First Name",
        "Birthdate",
        "Plan",
        "Day(s)",
        "Location",
        "Primary Parent",
        "Email",
        "Phone",
        "Secondary Contact",
        "Phone",
        "Emergency Contact",
        "Phone",
        "Medical",
        "Phone",
        "Dental",
        "Phone",
        "Insurance",
        "Policy Number",
        "Notes",
      ]

      self.all.each do |enrollment|
        account = enrollment.account
        primary_parent = account.primary_parent
        secondary_parent = account.secondary_parent
        emergency_contact = account.emergency_contacts.first

        account_info = primary_parent.present? ? [primary_parent.full_name] : [""]

        account_info << account.user.email

        account_info << (primary_parent.present? ? primary_parent.phone : "")

        account_info += secondary_parent.present? ? [secondary_parent.full_name, secondary_parent.phone] : ["", ""]

        account_info += emergency_contact.present? ? [emergency_contact.full_name, emergency_contact.phone] : ["", ""]

        account_info += [
          account.family_physician,
          account.physician_phone,
          account.family_dentist,
          account.dentist_phone,
          account.insurance_company,
          account.insurance_policy_number,
        ]

        child = enrollment.child

        child_info = [child.last_name, child.first_name, child.birthdate.stamp("5/13/2011"), enrollment.type_display, enrollment.service_dates, enrollment.location.name]

        child_info += account_info

        if child.care_items.active.any?
          notes = child.care_items.active.map{|item| "#{item.name}: #{item.explanation}"}.join("\n")
          unless child.additional_info.blank?
            notes += "\n#{child.additional_info}"
          end

          child_info << notes
        else
          child_info << ""
        end

        csv << child_info
      end
    end
  end

  def plan_type
    plan.plan_type if plan.present?
  end

  def recurring?
    plan_type.present? && plan_type.recurring?
  end

  def one_time?
    !recurring?
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

          info[month_name]["message"] = "#{cost_for_date(target_date)}#{" was" if target_payment_past} Due #{target_payment_today ? "Today" : "on #{target_payment_date.stamp("Aug. 1st, 2019")}"} for the month of #{month_name}"
        end

        target_date = target_date.end_of_month + 1.day
        month_name = target_date.stamp("February, 2019")
      end
    else
      info["One Time"] = {}
      if self.paid?
        info["One Time"]["message"] = "Paid #{last_paid_amount} on #{created_at.to_date.stamp("Aug. 1st, 2019")}"
      else
        info["One Time"]["message"] = "#{cost_for_date(target_date)} Due Today"
        info["One Time"]["overdue"] = true
      end
    end

    info
  end

  def set_next_target_and_payment_date(given_enrollment_transaction = nil)
    if plan_type.recurring?
      # update starts_at to make sure
      self.starts_at ||= [@program.starts_at.to_date, (created_at || Time.zone.today).to_date].max
      self.ends_at ||= @program.ends_at
      stop_date = nil

      latest_enrollment_transaction = given_enrollment_transaction || enrollment_transactions.paid.by_target_date.last

      stop_date = latest_enrollment_transaction.description_data["stop_date"] if latest_enrollment_transaction.present? && !latest_enrollment_transaction.placeholder?

      if stop_date.present?
        target_date = stop_date.to_date.end_of_month + 1.day # move forward a month
      else # unless we don't have any yet - then do the first one
        target_date = self.starts_at # figured that out above
      end

      self.next_target_date = target_date
      self.next_payment_date = target_date.beginning_of_month + child.account.payment_offset.days

      if next_payment_date <= Time.zone.today
        self.paid = false
      elsif next_payment_date > Time.zone.today
        self.paid = true
      end
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

  def cost_for_date(target_date)
    ap "trying to find cost for date for #{child.full_name} in program #{program.name} on target date #{target_date}"
    month_price = custom_price

    if month_price.present?
      month_price -= plan.discounts_for_date(target_date)
    else
      month_price = plan.price_for_date(target_date)

      # this plan type allows people to choose the days they'll attend, as well as the plan they want
      # so, find the percentage of the days they chose into the total allowed days, and alter the price accordingly
      if plan.plan_type.full_day_contract?
        days_attending = enrolled_days.count
        possible_days = plan.days_per_week

        if possible_days < 0
          possible_days = plan.allowed_days.count
        end

        percentage = days_attending.to_f / possible_days.to_f

        month_price = month_price * percentage
      end

      # recurring plans can start or end in the middle of a month, so we need to prorate the amount based on that
      if plan.plan_type.recurring?
        total_days = (target_date.beginning_of_month..target_date.end_of_month).to_a.select{|d| available_on_date?(d)}

        start_date = [self.starts_at, target_date.beginning_of_month].max
        stop_date = [self.ends_at, target_date.end_of_month].min
        used_days = total_days.select{|d| d >= start_date && d <= stop_date}

        percentage_used = used_days.count.to_f / total_days.count.to_f
        month_price = month_price * percentage_used
      end
    end

    month_price.to_money
    month_price = Money.new(0) if month_price < Money.new(0)
    month_price
  end

  def amount_due_today
    unless plan_type.recurring?
      return paid? ? Money.new(0) : cost_for_date(next_target_date)
    end

    result = Money.new(0)

    set_next_target_and_payment_date if next_target_date.blank? || next_payment_date.blank? # don't save it since they're not ready

    target_date = next_target_date
    payment_date = next_payment_date
    while target_date <= program.ends_at && payment_date <= Time.zone.today
      result += cost_for_date(target_date)
      target_date = target_date.end_of_month + 1.day
      payment_date = target_date + child.account.payment_offset.days
    end

    result
  end

  def display_amount_due_today
    set_next_target_and_payment_date if next_target_date.blank? # don't save it since they're not ready

    target_date = next_payment_date
    if target_date > Time.zone.today
      "#{Time.zone.today > self.starts_at ? "Next" : "First"} Payment on #{target_date.stamp("March 3rd, 2019")}"
    else
      amount_due_today.to_s
    end
  end

  def craft_enrollment_transactions(parent_transaction, given_amount = nil)
    unless plan_type.recurring?
      return if paid?
      EnrollmentTransaction.create(enrollment_id: self.id, my_transaction_id: parent_transaction.id, amount: given_amount || amount_due_today, target_date: self.next_target_date, description_data: {"description" => self.to_short, "start_date" => self.starts_at, "stop_date" => self.ends_at})
    else
      target_date = next_target_date
      payment_date = next_payment_date

      created_transaction = nil

      # create a blank transaction - that runs from today to the day before the enrollment starts (at which point another transaction should be created for that first payment) - for other changes to refer back to
      if self.starts_at > Time.zone.today
        created_transaction = EnrollmentTransaction.create(enrollment_id: self.id, my_transaction_id: parent_transaction.id, amount: Money.new(0), target_date: Time.zone.today, description_data: {"description" => self.to_short, "start_date" => Time.zone.today, "stop_date" => self.starts_at - 1.day})
      end

      while target_date <= program.ends_at && payment_date <= Time.zone.today
        stop_date = target_date.end_of_month
        created_transaction = EnrollmentTransaction.create(enrollment_id: self.id, my_transaction_id: parent_transaction.id, amount: cost_for_date(target_date), target_date: target_date, description_data: {"description" => self.to_short, "start_date" => target_date, "stop_date" => stop_date})
        target_date = stop_date + 1.day
        payment_date = target_date + child.account.payment_offset.days
      end
    end

    self.paid = true
    self.set_next_target_and_payment_date!
  end

  def transaction_for_target_date(given_date)
    enrollment_transactions.paid.where(target_date: given_date).reverse_chronological.first
  end

  def transaction_covers_date(given_date)
    enrollment_transactions.paid.where("description_data->'start_date' <= ? AND description_data->'stop_date' >= ?", given_date, given_date).chronological.first
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

  def alerts_enabled?
    program_location = program.program_locations.find_by(location_id: location.id)
    program_location.present? && program_location.enable_alerts?
  end

  def available_on_date?(target_date)
    return false if program.holidays.pluck(:holidate).include?(target_date)

    day_num = target_date.wday
    send(DAY_DICTIONARY[day_num])
  end

  def enrolled_on_date?(target_date)
    return false if target_date < program.starts_at || target_date > program.ends_at
    available_on_date?(target_date)
  end

  def enrolled_today?
    enrolled_on_date?(Time.zone.today)
  end

  private

  def deduce_plan
    return if self.plan.blank? || self.plan.choosable? # don't worry about restrictions if the plan is a manual choice

    target_days = enrolled_days.sort
    num_days = target_days.count

    return if num_days == 0

    # leave the current plan if it is "allowed"
    # -1 plan days_per_week means that they want to allow any number of days.
    return if [-1, num_days].include?(self.plan.days_per_week.to_i) && (target_days & self.plan.allowed_days).sort == target_days

    target_program = plan.program
    target_plan_type = plan.plan_type
    possible_plans = program.plans.by_plan_type(target_plan_type)

    success = false

    possible_plans.find_each do |possible_plan|
      if [-1, num_days].include?(possible_plan.days_per_week.to_i) && (target_days & possible_plan.allowed_days).sort == target_days
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
    if plan_type.present? && plan_type.one_time?
      self.ends_at = self.starts_at
      errors.add(:base, "#{child.first_name} cannot attend on #{starts_at.stamp("Mar. 3rd, 2018")} as we are closed for Independance Day") if starts_at.month == 7 && starts_at.day == 4

      errors.add(:base, "#{child.first_name} cannot attend on #{starts_at.stamp("Mar. 3rd, 2018")} as we are on holiday!") if program.holidays.pluck(:holidate).include?(starts_at)
    end

    if program.present?
      starts_at.present?
      if self.starts_at.present? && self.starts_at < program.starts_at
        errors.add(:base, "#{child.first_name} cannot attend on #{self.starts_at.stamp("Mar. 3rd, 2018")} as #{program.name} only runs from #{program.starts_at} to #{program.ends_at}")
      end

      if self.ends_at.present? && self.ends_at > program.ends_at
        errors.add(:base, "#{child.first_name} cannot attend on #{self.ends_at.stamp("Mar. 3rd, 2018")} as #{program.name} only runs from #{program.starts_at} to #{program.ends_at}")
      end
    end

    if starts_at.present? && ends_at.present? && ([0, 6] & (starts_at.wday..ends_at.wday).to_a).any?
      errors.add(:base, "#{child.first_name} cannot attend on #{starts_at.stamp("Mar. 3rd, 2018")} because we are only in session on weekdays")
    end
  end
end
