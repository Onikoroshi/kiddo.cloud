class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :program

  has_many :enrollment_transactions, foreign_key: :my_transaction_id, dependent: :destroy
  has_many :enrollments, through: :enrollment_transactions

  classy_enum_attr :transaction_type
  money_column :amount

  scope :chronological, -> { order("created_at ASC") }
  scope :reverse_chronological, -> { order("created_at DESC") }
  scope :paid, -> { where(paid: true) }
  scope :unpaid, -> { where.not(paid: true) }

  def itemization_total
    total = 0.00
    itemizations.each do |_k, v|
      total += v.to_f
    end
    total
  end
end
