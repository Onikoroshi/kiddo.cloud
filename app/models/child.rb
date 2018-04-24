class Child < ApplicationRecord
  include ClassyEnum::ActiveRecord

  belongs_to :account
  has_and_belongs_to_many :parents
  has_one :attendance_selection, dependent: :destroy

  has_many :drop_ins, dependent: :destroy

  has_many :child_locations, dependent: :destroy # don't use these anymore

  has_many :enrollments, dependent: :destroy
  has_many :plans, through: :enrollments
  has_many :locations, through: :enrollments

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

  classy_enum_attr :gender

  scope :low_grade, -> { where(grade_entering: ["1", "2", "3"]) }
  scope :high_grade, -> { where(grade_entering: ["4", "5", "6"]) }

  AVAILABLE_GRADES = (["TK", "K"] + (1..6).to_a.map(&:to_s))

  def self.available_grades
    AVAILABLE_GRADES
  end

  def self.active_locations
    location_ids = self.joins(enrollments: :program).where.not(enrollments: {dead: true}).where("programs.ends_at >= ?", Time.zone.today).distinct.pluck("enrollments.location_id").uniq
    Location.where(id: location_ids)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def active_enrollment_blurbs
    enrollments.alive.active_blurbs(self)
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
    enrollments.alive.where(plan: program.plans).present?
  end

  def scheduled_for_today?(program)
    enrollments.alive.where(plan: program.plans).select { |e| e.enrolled_today? }.any?
  end

  def last_time_entry
    time_entries.last
  end

  def on_clock?
    return false unless last_time_entry.present?
    last_time_entry.record_type == "entry"
  end

  def overlapping_enrollment_dates(given_enrollments)
    ignore = []
    failed_messages = []

    given_enrollments.each do |a|
      given_enrollments.reject{ |e| (ignore + [a.id]).include?(e.id) }.each do |b|
        overlap = (a.starts_at <= b.starts_at && a.ends_at >= b.ends_at)    ||  # a completely contains b
                  (a.starts_at <= b.starts_at && a.ends_at >= b.starts_at)  ||  # a contains b start (b contains a end)
                  (a.starts_at <= b.ends_at && a.ends_at >= b.ends_at)      ||  # a contains b end (b contains a end)
                  (b.starts_at <= a.starts_at && b.ends_at >= a.ends_at)        # b completely contains a

        # recurring plans are a special case - they can overlap others' dates, but not overlap the specific day of the week
        # Example: Contract for M, W, F in Program from 4/1/2018 - 5/1/2018 could overlap a Drop-In on 4/17/2018, but since that is a Tuesday, it doesn't actually overlap because the contract is not on Tuesdays.
        if overlap && (a.plan_type.recurring? || b.plan_type.recurring?)
          overlap = (a.enrolled_days & b.enrolled_days).any?
        end

        if overlap
          ignore << a.id
          ignore << b.id
          ignore = ignore.uniq
          failed_messages << "#{self.first_name}'s #{a.plan_type.text} enrollment #{a.display_dates} overlaps with #{self.gender.possessive} #{b.plan_type.text} enrollment #{b.display_dates}"
        end
      end
    end

    failed_messages
  end
end
