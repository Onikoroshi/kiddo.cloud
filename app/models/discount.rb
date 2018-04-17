class Discount < ApplicationRecord
  belongs_to :plan

  money_column :amount
  classy_enum_attr :month, enum: "DiscountMonth"

  validates :plan, :amount, :month, presence: true

  def to_s
    "#{amount.to_s} for #{month.text}"
  end
end
