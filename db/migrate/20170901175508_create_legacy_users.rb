class CreateLegacyUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :legacy_users do |t|
      t.string :email
      t.date :paid_through
      t.timestamps
    end
  end
end
