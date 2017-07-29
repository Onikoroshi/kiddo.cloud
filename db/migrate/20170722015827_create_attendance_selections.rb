class CreateAttendanceSelections < ActiveRecord::Migration[5.1]
  def change
    create_table :attendance_selections do |t|
      t.references :child, foreign_key: true
      t.boolean :monday, default: false
      t.boolean :tuesday, default: false
      t.boolean :wednesday, default: false
      t.boolean :thursday, default: false
      t.boolean :friday, default: false
      t.boolean :saturday, default: false
      t.boolean :sunday, default: false

      t.timestamps
    end
  end
end
