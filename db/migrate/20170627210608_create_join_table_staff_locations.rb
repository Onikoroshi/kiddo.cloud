class CreateJoinTableStaffLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :staff_locations do |t|
      t.references :staff, index: true
      t.references :location, index: true
    end
  end
end