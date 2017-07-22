class CreateAttendancePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :attendance_plans do |t|
      t.references :child, foreign_key: true
      t.references :program, foreign_key: true
      t.boolean :monday
      t.boolean :tuesday
      t.string :wednesday_boolean
      t.string :thursday_boolean
      t.boolean :friday
      t.boolean :saturday
      t.boolean :sunday

      t.timestamps
    end
  end
end
