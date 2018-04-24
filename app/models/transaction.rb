class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :program # not used

  has_many :enrollment_transactions, foreign_key: :my_transaction_id, dependent: :destroy
  has_many :enrollments, through: :enrollment_transactions

  belongs_to :parent, class_name: "Transaction"
  has_many :refunds, inverse_of: :parent, foreign_key: :parent_id, class_name: "Transaction"

  has_many :enrollment_change_transactions, foreign_key: :my_transaction_id, dependent: :destroy
  has_many :enrollment_changes, through: :enrollment_change_transactions

  classy_enum_attr :transaction_type
  money_column :amount

  after_create :initialize_receipt_number

  scope :chronological, -> { order("created_at ASC") }
  scope :reverse_chronological, -> { order("created_at DESC") }
  scope :paid, -> { where(paid: true) }
  scope :unpaid, -> { where.not(paid: true) }

  def has_changes?
    enrollment_change_transactions.any? || enrollments.joins(:enrollment_changes).any?
  end

  def pending_enrollment_changes
    EnrollmentChange.where(enrollment: enrollments).pending
  end

  def itemization_total
    total = 0.00
    itemizations.each do |_k, v|
      total += v.to_f
    end
    total
  end

  def refund?
    transaction_type.present? && transaction_type.refund?
  end

  def adjusted_amount
    refund? ? amount * -1 : amount
  end

  def net_total
    total_refund = refunds.inject(Money.new(0)){|sum, refund| sum + refund.amount}
    amount - total_refund
  end

  private

  def initialize_receipt_number
    update_attribute(:receipt_number, SecureRandom.hex(6))
  end
end
