class AddLateFeeToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :late_fee, :float, default: 0.0
  end
end
