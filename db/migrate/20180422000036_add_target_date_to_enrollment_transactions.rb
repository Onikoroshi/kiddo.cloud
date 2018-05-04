class AddTargetDateToEnrollmentTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :enrollment_transactions, :target_date, :date
  end
end
