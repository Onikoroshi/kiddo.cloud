class AdjustUserIdOnTimeDisputes < ActiveRecord::Migration[5.1]
  def change
    remove_column :time_disputes, :users_id
    add_column :time_disputes, :user_id, :integer, index: true
  end
end
