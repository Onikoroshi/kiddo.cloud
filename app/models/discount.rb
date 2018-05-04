class Discount < ApplicationRecord
  belongs_to :plan

  money_column :amount
  classy_enum_attr :month, enum: "DiscountMonth"

  validates :plan, :amount, :month, presence: true

  scope :by_month, ->(given_date) { given_date.respond_to?(:stamp) ? where(month: given_date.stamp("january").downcase) : none }

  def to_s
    "#{amount.to_s} for #{month.text}"
  end
end
