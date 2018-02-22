class EnrollmentTransaction < ApplicationRecord
  belongs_to :enrollment
  belongs_to :my_transaction, class_name: "Transaction"
end
