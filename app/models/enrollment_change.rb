class EnrollmentChange < ApplicationRecord
  belongs_to :account
  belongs_to :enrollment

  has_many :enrollment_change_transactions, dependent: :destroy
  has_many :transactions, through: :enrollment_change_transactions, source: :my_transaction

  money_column :amount

  validates :account, :enrollment, presence: true

  after_create :update_amount
  after_save :update_amount

  scope :require_fee, -> { where(requires_fee: true) }
  scope :require_refund, -> { where(requires_refund: true) }
  scope :finalized, -> { where(applied: true) }
  scope :pending, -> { where.not(applied: true) }
  scope :by_program, ->(given_program) { given_program.present? ? joins(enrollment: :program).where("programs.id = ?", given_program.id) : all }

  def self.generating_charge
    self.pending.require_refund.select{|change| change.amount >= 0}
  end

  def self.generating_refund
    self.pending.require_refund.select{|change| change.amount < 0}
  end

  def self.charge_total
    pending.require_refund.inject(Money.new(0)){|sum, change| sum + change.charge_amount}
  end

  def self.refund_total
    pending.require_refund.inject(Money.new(0)){|sum, change| sum + change.refund_amount}
  end

  def self.transactions
    transaction_ids = self.joins(enrollment: :transactions).pluck("transactions.id").uniq
    Transaction.where(id: transaction_ids)
  end

  def self.build_params
    params = { "children_attributes" => {} }

    max_child_index = 0
    max_enrollment_index = 0
    self.find_each do |enrollment_change|
      enrollment_change.update_attribute(:data, {}) if enrollment_change.data.nil?
      enrollment = enrollment_change.enrollment

      child_index = params["children_attributes"].select{|key, values| values["id"] == enrollment.child_id}.keys.first

      if child_index.blank?
        child_index = max_child_index.to_s
        max_child_index += 1
      end

      params["children_attributes"][child_index] = {id: enrollment.child_id} if params["children_attributes"][child_index].nil?
      params["children_attributes"][child_index]["enrollments_attributes"] = {} if params["children_attributes"][child_index]["enrollments_attributes"].nil?

      enrollment_index = params["children_attributes"][child_index]["enrollments_attributes"].select{|key, values| values["id"] == enrollment.id}.keys.first

      if enrollment_index.blank?
        enrollment_index = max_enrollment_index.to_s
        max_enrollment_index += 1
      end

      params["children_attributes"][child_index]["enrollments_attributes"][enrollment_index] = {id: enrollment.id} if params["children_attributes"][child_index]["enrollments_attributes"][enrollment_index].nil?

      existing_enrollment_params = params["children_attributes"][child_index]["enrollments_attributes"][enrollment_index]
      target_enrollment_params = existing_enrollment_params.merge!(enrollment_change.data)

      if enrollment_change.data.keys.include?("_destroy")
        target_enrollment_params.merge!({
          "monday" => false,
          "tuesday" => false,
          "wednesday" => false,
          "thursday" => false,
          "friday" => false,
        })
      end

      params["children_attributes"][child_index]["enrollments_attributes"][enrollment_index] = target_enrollment_params
    end

    params
  end

  def pending?
    !applied?
  end

  def apply_to_enrollment!
    raise ActiveRecord::RecordNotFound if enrollment.blank?
    final_description = build_description(true)

    if data.keys.include?("_destroy")
      enrollment.kill!
    else
      enrollment.update_attributes!(data)
      enrollment.resurrect!
    end

    update_attribute(:applied, true)
    update_attribute(:description, final_description)
  end

  def build_description(past = false)
    if data["_destroy"].present?
      return "Remove#{"d" if past} this Enrollment"
    end

    messages = []
    if data["starts_at"].present? && data["ends_at"].present?
      if enrollment.plan_type.weekly?
        messages << "Change#{"d" if past} week from #{enrollment.service_dates} to #{DateTool.display_week(data["starts_at"].to_date, data["ends_at"].to_date)}"
      elsif enrollment.plan_type.drop_in?
        messages << "Change#{"d" if past} date from #{enrollment.service_dates} to #{data["starts_at"].to_date.stamp("Monday, Feb. 3rd, 2018")}"
      else
        messages << "Change#{"d" if past} start date from #{enrollment.starts_at.stamp("Monday, Feb. 3rd, 2018")} to #{data["starts_at"].to_date.stamp("Monday, Feb. 3rd, 2018")} and end date from #{enrollment.ends_at.stamp("Monday, Feb. 3rd, 2018")} to #{data["ends_at"].to_date.stamp("Monday, Feb. 3rd, 2018")}"
      end
    elsif data["starts_at"].present?
      messages << "Change#{"d" if past} start date from #{enrollment.starts_at.stamp("Monday, Feb. 3rd, 2018")} to #{data["starts_at"].to_date.stamp("Monday, Feb. 3rd, 2018")}"
    elsif data["ends_at"].present?
      messages << "Change#{"d" if past} end date from #{enrollment.ends_at.stamp("Monday, Feb. 3rd, 2018")} to #{data["ends_at"].to_date.stamp("Monday, Feb. 3rd, 2018")}"
    end

    if enrollment.plan.choosable? && data["plan_id"].present? && Plan.find_by(id: data["plan_id"]).present?
      messages << "Change#{"d" if past} from #{enrollment.plan.display_name} to #{Plan.find_by(id: data["plan_id"]).display_name}"
    end

    if enrollment.plan_type.recurring?
      affected_days = (["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"] & data.keys.map(&:to_s))

      if affected_days.any?
        added_days = []
        removed_days = []

        affected_days.each do |day_str|
          if data[day_str]
            added_days << day_str
          else
            removed_days << day_str
          end
        end

        before_days = enrollment.enrolled_days.map(&:to_s)
        after_days = (before_days + added_days) - removed_days

        messages << "Change#{"d" if past} from #{before_days.map{|d| d.to_s.capitalize.pluralize}.to_sentence} to #{after_days.map{|d| d.to_s.capitalize.pluralize}.to_sentence}"
      end
    end

    if data["location_id"].present? && Location.find_by(id: data["location_id"]).present?
      messages << "Move#{"d" if past} from #{enrollment.location.present? ? enrollment.location.name : "unknown location"} to #{Location.find_by(id: data["location_id"]).name}"
    end

    messages.to_sentence
  end

  def calculated_amount
    return Money.new(0) unless data.is_a?(Hash)

    if enrollment.plan_type.recurring?
      # This has a HUGE exploit. If a parent keeps changing their date back by one day at a time,
      # it will keep refunding them. We'll need a significant refactor to prevent that,
      # so just disable for now
      # if data["ends_at"].present? && data["ends_at"].to_date < enrollment.ends_at
      #   target_stop = data["ends_at"].to_date
      #   refund_amount = Money.new(0)
      #   enrollment.enrollment_transactions.each do |et|
      #     ap "et start #{et.start_date}"
      #     ap "et stop #{et.stop_date}"
      #     ap "target stop #{target_stop}"
      #     ap "enrollment stop #{enrollment.ends_at}"
      #     if et.stop_date > target_stop && et.start_date <= enrollment.ends_at
      #       ap "et stop #{et.stop_date} greater than target #{target_stop}"
      #       if et.start_date >= target_stop
      #         ap "et start #{et.start_date} greater than target #{target_stop}"
      #         refund_amount -= et.amount
      #       else
      #         ap "et start #{et.start_date} less than target #{target_stop}"
      #         actual_cost = enrollment.cost_for_date(target_stop, target_start: et.start_date, target_stop: target_stop)
      #         refund_amount -= (et.amount - actual_cost)
      #       end
      #     end
      #   end
      #   refund_amount
      # else
      #   Money.new(0)
      # end
      Money.new(0)
    else
      if data["_destroy"].present?
        enrollment.last_paid_amount * -1 # this will be the refund amount
      elsif data["plan_id"].present? && Plan.find_by(id: data["plan_id"]).present?
        old_plan = enrollment.plan
        new_plan = Plan.find_by(id: data["plan_id"])

        new_plan.price - old_plan.price
      else
        Money.new(0)
      end
    end
  end

  def charge_amount
    [Money.new(0), amount].max
  end

  def refund_amount
    [Money.new(0), amount].min.abs
  end

  private

  def update_amount
    return unless saved_changes?
    return if saved_change_to_amount?
    return unless pending?

    if requires_refund?
      update_attribute(:amount, calculated_amount)
    else
      update_attribute(:amount, 0.0)
    end
  end
end
