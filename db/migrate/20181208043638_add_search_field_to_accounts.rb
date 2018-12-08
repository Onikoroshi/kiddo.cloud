class AddSearchFieldToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :search_field, :text, default: ""
  end
end
