class Child < ApplicationRecord
  belongs_to :account
  has_many :children_parents
  has_many :parents, through: :children_parents

  has_many :child_locations
  has_many :locations, through: :child_locations

  has_many :attendance_plans
  has_many :programs, through: :attendance_plans

  has_many :time_entries, as: :time_recordable
  has_many :care_items, dependent: :destroy

  after_initialize :build_default_care_items

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :gender, presence: true
  validates :birthdate, presence: true

  accepts_nested_attributes_for :care_items, allow_destroy: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def build_default_care_items
    if self.care_items.empty?
      self.care_items.build(name: "Allergies (Insects/Food)")
      self.care_items.build(name: "Learning Disorder")
      self.care_items.build(name: "Dietary Needs")
      self.care_items.build(name: "Special Physical/Emotional Needs")
      self.care_items.build(name: "Current Medications")
    end
  end
end
