class AddDeduceToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :deduce, :boolean, default: false
  end
end
