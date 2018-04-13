class CreateEnrollmentChangeTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :enrollment_change_transactions do |t|
      t.references :enrollment_change, index: true
      t.references :my_transaction, index: true, foreign_key: { to_table: :transactions }
      t.float :amount

      t.timestamps
    end
  end
end
