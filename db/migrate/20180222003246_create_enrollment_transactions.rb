class CreateEnrollmentTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :enrollment_transactions do |t|
      t.references :enrollment, index: true
      t.references :my_transaction, index: true, foreign_key: { to_table: :transactions }
      t.float :amount

      t.timestamps
    end
  end
end
