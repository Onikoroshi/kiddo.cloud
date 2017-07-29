class CreatePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :plans do |t|
      t.references :program, foreign_key: true
      t.string :name
      t.integer :days_per_week
      t.float :price
      t.string :plan_type

      t.timestamps
    end
  end
end
