class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.references :user, index: true
      t.string :name
      t.string :subdomain
      t.integer :user_id

      t.timestamps
    end
  end
end
