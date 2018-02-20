class CreateProgramLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :program_locations do |t|
      t.references :program, index: true
      t.references :location, index: true
      t.timestamps
    end
  end
end
