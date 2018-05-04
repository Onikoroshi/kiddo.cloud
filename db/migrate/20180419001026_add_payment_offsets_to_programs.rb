class AddPaymentOffsetsToPrograms < ActiveRecord::Migration[5.1]
  def change
    add_column :programs, :earliest_payment_offset, :integer, default: -15
    add_column :programs, :latest_payment_offset, :integer, default: 15
  end
end
