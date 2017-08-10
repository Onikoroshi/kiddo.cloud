class DropIn < ApplicationRecord
  belongs_to :account
  belongs_to :child
  belongs_to :program

  money_column :price

  validates :date, presence: true
  validates :time_slot, presence: true
  validate :validate_date_within_range

  def wednesday?
    date.wednesday?
  end

  def validate_date_within_range
    return if date.blank?
    errors.add(:date, "must be from today till the end of #{program.name}") unless date_in_range?
  end

  def date_in_range?
    return false unless program.present?
    ((Time.zone.today)..(program.ends_at)).include?(self.date)
  end

  def to_s
    "#{child.full_name} is scheduled to be dropped in on #{date.stamp("March 1, 2029")} from #{translate_time_slot}."
  end

  def translate_time_slot
    case time_slot
    when "full_day"
      "8am - 6pm"
    when "morning"
      "8am - 1pm"
    when "afternoon"
      "1pm - 6pm"
    else
      "undetermined"
    end
  end
end
