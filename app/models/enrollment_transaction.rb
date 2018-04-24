class EnrollmentTransaction < ApplicationRecord
  belongs_to :enrollment
  belongs_to :my_transaction, class_name: "Transaction"

  money_column :amount

  scope :reverse_chronological, -> { order("enrollment_transactions.created_at DESC") }
  scope :by_target_date, -> { order("enrollment_transactions.target_date ASC") }
  scope :paid, -> { joins(:my_transaction).where("transactions.paid IS TRUE") }
end
