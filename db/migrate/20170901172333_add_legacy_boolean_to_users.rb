class AddLegacyBooleanToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :legacy, :boolean, default: false
  end
end
