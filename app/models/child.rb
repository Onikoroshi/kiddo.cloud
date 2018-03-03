class Child < ApplicationRecord
  belongs_to :account
  has_and_belongs_to_many :parents
  has_one :attendance_selection, dependent: :destroy

  has_many :drop_ins, dependent: :destroy

  has_many :child_locations, dependent: :destroy
  has_many :locations, through: :child_locations

  has_many :enrollments, dependent: :destroy
  has_many :plans, through: :enrollments

  has_many :time_entries, as: :time_recordable
  has_many :care_items, dependent: :destroy

  has_many :late_checkin_notifications, dependent: :destroy

  after_initialize :build_default_care_items

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :gender, presence: true
  validates :birthdate, presence: true

  accepts_nested_attributes_for :enrollments, allow_destroy: true
  accepts_nested_attributes_for :care_items, allow_destroy: true
  accepts_nested_attributes_for :attendance_selection, allow_destroy: true
  accepts_nested_attributes_for :drop_ins, allow_destroy: true, reject_if: :all_blank

  scope :low_grade, -> { where(grade_entering: ["1", "2", "3"]) }
  scope :high_grade, -> { where(grade_entering: ["4", "5", "6"]) }

  AVAILABLE_GRADES = (["TK", "K"] + (1..6).to_a.map(&:to_s))

  def self.available_grades
    AVAILABLE_GRADES
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def build_default_care_items
    if care_items.empty?
      care_items.build(name: "Allergies (Insects/Food)")
      care_items.build(name: "Dietary Needs")
      care_items.build(name: "Special Health or Emotional Needs")
      care_items.build(name: "Current Medications")
    end
  end

  def siblings?
    account.children.count > 1
  end

  def enrolled?(program)
    enrollments.where(plan: program.plans).present?
  end

  def scheduled_for_today?(program)
    drop_ins.today.any? ||
      enrolled?(program) &&
        enrollments.where(plan: program.plans).select { |e| e.enrolled_today? }.any?
  end

  def last_time_entry
    time_entries.last
  end

  def on_clock?
    return false unless last_time_entry.present?
    last_time_entry.record_type == "entry"
  end

  def overlapping_enrollment_dates(program)
    enrollments = self.enrollments.by_program(program)
    ignore = []
    failed_messages = []

    enrollments.find_each do |a|
      enrollments.where.not(id: ignore + [a.id]).find_each do |b|
        overlap = (a.starts_at <= b.starts_at && a.ends_at >= b.ends_at)    ||  # a completely contains b
                  (a.starts_at <= b.starts_at && a.ends_at >= b.starts_at)  ||  # a contains b start (b contains a end)
                  (a.starts_at <= b.ends_at && a.ends_at >= b.ends_at)      ||  # a contains b end (b contains a end)
                  (b.starts_at <= a.starts_at && b.ends_at >= a.ends_at)        # b completely contains a

        if overlap
          ignore << a
          ignore << b
          ignore = ignore.uniq
          failed_messages << "#{a.plan_type.text} enrollment #{a.display_dates} overlaps with a #{b.plan_type.text} enrollment #{b.display_dates}"
        end
      end
    end

    failed_messages
  end
end
