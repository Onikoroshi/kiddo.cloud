class CreateEnrollments < ActiveRecord::Migration[5.1]
  def change
    create_table :enrollments do |t|
      t.references :child, foreign_key: true
      t.references :plan, foreign_key: true

      t.timestamps
    end
  end
end
