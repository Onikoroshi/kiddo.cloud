class AddPrimaryLocationToAccount < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :location_id, :integer
  end
end
