class DropIn < ApplicationRecord
  belongs_to :account
  belongs_to :child
  belongs_to :program

  scope :upcoming, -> { where("drop_ins.date >= ?", Time.zone.today.beginning_of_day) }
  scope :not_paid, -> { where(paid: false) }
  scope :today, -> {
    where(date:
      DateTime.now.beginning_of_day..DateTime.now.end_of_day)
  }

  money_column :price, currency: 'USD'

  validates :date, presence: true
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
    ((Time.zone.today)..(program.ends_at)).cover?(date)
  end

  def to_s
    "#{child.full_name} is scheduled to be dropped in on #{date.stamp('March 1, 2029')} at #{account.location.name}."
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
