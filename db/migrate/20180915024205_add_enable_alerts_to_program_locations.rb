class AddEnableAlertsToProgramLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :program_locations, :enable_alerts, :boolean, default: false
  end
end
