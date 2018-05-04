class AddPaymentOffsetToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :payment_offset, :integer, default: 0
  end
end
