class Discount < ApplicationRecord
  belongs_to :plan

  money_column :amount
  classy_enum_attr :month, enum: "DiscountMonth"

  validates :plan, :amount, :starts_on, :stops_on, presence: true
  validate :validate_start_stop_order

  scope :cover_date, ->(given_date) { given_date.respond_to?(:to_date) ? where("discounts.starts_on <= ? AND discounts.stops_on >= ?", given_date.to_date, given_date.to_date) : none }

  def to_s
    "#{amount.to_s} for #{starts_on.stamp("Aug. 25th, 2019")} - #{stops_on.stamp("Aug. 25th, 2019")}"
  end

  private

  def validate_start_stop_order
    if starts_on.present? && stops_on.present?
      errors.add(:stops_on, "Discount stop date #{stops_on} cannot be before start date: #{starts_on}") if stops_on < starts_on
    end
  end
end
