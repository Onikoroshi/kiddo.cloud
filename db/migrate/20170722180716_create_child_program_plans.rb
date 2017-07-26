class CreateChildProgramPlans < ActiveRecord::Migration[5.1]
  def change
    create_table :child_program_plans do |t|
      t.references :child, foreign_key: true
      t.references :program_plan, foreign_key: true

      t.timestamps
    end
  end
end
