class CreateProgramPlans < ActiveRecord::Migration[5.1]
  def change
    create_table :program_plans do |t|
      t.references :program, foreign_key: true
      t.string :name
      t.integer :days_per_week
      t.float :price

      t.timestamps
    end
  end
end
