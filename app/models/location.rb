class Location < ApplicationRecord
  belongs_to :center
  has_one :address, as: :addressable
  has_many :time_entries, dependent: :destroy
  has_many :enrollments
  has_many :transactions, through: :enrollments

  has_many :child_locations, dependent: :destroy
  has_many :children, through: :child_locations

  has_many :staff_locations, dependent: :destroy
  has_many :staff, through: :staff_locations

  has_many :program_locations, dependent: :destroy
  has_many :programs, through: :program_locations

  validates :name, presence: true

  # get a unique list of programs associated with a set of locations
  def self.programs
    Program.where(id: self.joins(:programs).pluck("programs.id").uniq)
  end

  def default?
    default
  end

  def can_destroy?
    return false if enrollments.any?
    return false if transactions.any?

    true
  end
end
