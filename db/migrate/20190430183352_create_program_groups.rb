class CreateProgramGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :program_groups do |t|
      t.string :title
      t.references :center, foreign_key: true
    end
  end
end
