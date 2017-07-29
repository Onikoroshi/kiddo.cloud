class CreateAttendanceSelections < ActiveRecord::Migration[5.1]
  def change
    create_table :attendance_selections do |t|
      t.references :child, foreign_key: true
      t.boolean :monday
      t.boolean :tuesday
      t.boolean :wednesday
      t.boolean :thursday
      t.boolean :friday
      t.boolean :saturday
      t.boolean :sunday

      t.timestamps
    end
  end
end
