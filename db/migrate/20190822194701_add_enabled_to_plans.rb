class AddEnabledToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :enabled, :boolean, default: true
  end
end
