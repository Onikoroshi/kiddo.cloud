class DropIn < ApplicationRecord
  belongs_to :account
  belongs_to :child
  belongs_to :program

  money_column :price

  validates :date, presence: true
  validate :validate_date_within_range

  def wednesday?
    date.wednesday?
  end

  def validate_date_within_range
    errors.add(:date, "is out of range") unless date_in_range?
  end

  def date_in_range?
    return false unless program.present?
    ((program.starts_at)..(program.ends_at)).include?(self.date)
  end
end
