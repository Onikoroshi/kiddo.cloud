class AddAllowedDaysToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :monday, :boolean, default: false
    add_column :plans, :tuesday, :boolean, default: false
    add_column :plans, :wednesday, :boolean, default: false
    add_column :plans, :thursday, :boolean, default: false
    add_column :plans, :friday, :boolean, default: false
    add_column :plans, :saturday, :boolean, default: false
    add_column :plans, :sunday, :boolean, default: false
  end
end
