class Child < ApplicationRecord
  belongs_to :account
  has_many :children_parents
  has_many :parents, through: :children_parents
  has_many :time_entries, as: :time_recordable

  has_many :child_locations
  has_many :locations, through: :child_locations

  has_many :care_items, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :gender, presence: true
  validates :birthdate, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def build_default_care_items
    self.care_items << CareItem.new(name: "Allergies")
    self.care_items << CareItem.new(name: "Learning Disorder")
    self.care_items << CareItem.new(name: "Dietary Needs")
    self.care_items << CareItem.new(name: "Special Physical/Emotional Needs")
    self.care_items << CareItem.new(name: "Current Medications")
  end
end
