class AddDjusdLunchIdToChildren < ActiveRecord::Migration[5.1]
  def change
    add_column :children, :djusd_lunch_id, :string
  end
end
