class CreateEmergencyContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :emergency_contacts do |t|
      t.references :account, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :phone

      t.timestamps
    end
  end
end
