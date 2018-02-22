class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :program

  has_many :enrollment_transactions, foreign_key: :my_transaction_id, dependent: :destroy
  has_many :enrollments, through: :enrollment_transactions

  classy_enum_attr :transaction_type

  def itemization_total
    total = 0.00
    itemizations.each do |_k, v|
      total += v.to_f
    end
    total
  end
end
