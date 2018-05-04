class AddPaymentTargetDatesToEnrollments < ActiveRecord::Migration[5.1]
  def change
    add_column :enrollments, :next_target_date, :date
    add_column :enrollments, :next_payment_date, :date
  end
end
