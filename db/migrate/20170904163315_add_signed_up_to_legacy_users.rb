class AddSignedUpToLegacyUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :legacy_users, :reregistered, :boolean, default: false
    add_column :legacy_users, :completed_signed_up, :boolean, default: false
  end
end
