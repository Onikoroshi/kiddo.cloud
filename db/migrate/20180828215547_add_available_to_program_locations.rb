class AddAvailableToProgramLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :program_locations, :available, :boolean, default: true
  end
end
