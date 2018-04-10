class AddInfoToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :parent_id, :bigint
    add_column :transactions, :gateway_id, :string
    add_column :transactions, :receipt_number, :string
  end
end
