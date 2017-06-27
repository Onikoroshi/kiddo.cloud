class CreateJoinTableChildLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :child_locations do |t|
      t.references :child, index: true
      t.references :location, index: true
    end
  end
end