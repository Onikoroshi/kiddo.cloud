class CreateCores < ActiveRecord::Migration[5.1]
  def change
    create_table :cores do |t|
      t.references :center, foreign_key: true
      t.string :last_registration_step_completed
      t.timestamps
    end
  end
end
