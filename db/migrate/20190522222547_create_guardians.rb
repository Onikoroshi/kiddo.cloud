class CreateGuardians < ActiveRecord::Migration[5.1]
  def change
    create_table :guardians do |t|
      t.string :first
      t.string :last
      t.integer :phone
      t.integer :account_id

      t.timestamps
    end
  end
end
