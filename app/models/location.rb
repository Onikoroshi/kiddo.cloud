class Location < ApplicationRecord
  belongs_to :center
  has_one :address, as: :addressable
  has_many :time_entries
  has_many :enrollments

  has_many :child_locations
  has_many :children, through: :child_locations

  has_many :staff_locations
  has_many :staff, through: :staff_locations

  def default?
    default
  end
end
