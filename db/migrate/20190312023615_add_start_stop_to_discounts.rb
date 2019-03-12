class AddStartStopToDiscounts < ActiveRecord::Migration[5.1]
  def change
    add_column :discounts, :starts_on, :date
    add_column :discounts, :stops_on, :date
  end
end
