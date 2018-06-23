class CreateTargetDays < ActiveRecord::Migration[5.1]
  def change
    create_table :target_days do |t|
      t.date :target_date
      t.references :plan, foreign_key: true

      t.timestamps
    end
  end
end
