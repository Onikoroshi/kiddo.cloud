class Staff < ApplicationRecord
  belongs_to :user
  has_many :time_entries, as: :time_recordable, dependent: :destroy

  has_many :staff_locations, dependent: :destroy
  has_many :locations, through: :staff_locations

  delegate :full_name, to: :user

  accepts_nested_attributes_for :user

  after_create :initialize_pin_number

  def manageable_locations
    if user.super_admin?
      Location.all
    elsif user.director?
      locations
    else
      Location.none
    end
  end

  def last_time_entry
    self.time_entries.last
  end

  def on_clock?
    return false unless last_time_entry.present?
    last_time_entry.record_type.entry?
  end

  def generate_pin_number
    "%04d" % SecureRandom.random_number(10000)
  end

  def set_pin_number
    existing = Staff.pluck(:pin_number)
    attempt = generate_pin_number
    while existing.include?(attempt)
      attempt = generate_pin_number
    end

    update_attribute(:pin_number, attempt)
  end

  def initialize_pin_number
    set_pin_number if self.pin_number.blank?
  end
end
