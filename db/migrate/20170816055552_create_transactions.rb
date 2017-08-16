class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.references :account, foreign_key: true
      t.references :program, foreign_key: true
      t.string :transaction_type
      t.integer :month
      t.integer :year
      t.float :amount
      t.boolean :paid, default: false

      t.timestamps
    end
  end
end
