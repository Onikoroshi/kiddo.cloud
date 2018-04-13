class EnrollmentChangeTransaction < ApplicationRecord
  belongs_to :enrollment_change
  belongs_to :my_transaction, class_name: "Transaction"
end
