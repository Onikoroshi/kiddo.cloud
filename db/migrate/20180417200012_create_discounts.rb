class CreateDiscounts < ActiveRecord::Migration[5.1]
  def change
    create_table :discounts do |t|
      t.references :plan, index: true
      t.float :amount
      t.string :month

      t.timestamps
    end
  end
end
