class CreateParents < ActiveRecord::Migration[5.1]
  def change
    create_table :parents do |t|
      t.references :user, index: true
      t.references :account, index: true
      t.string :first_name
      t.string :last_name
      t.boolean :primary, default: false
      t.string :phone
      t.string :email
      t.string :signature
      t.boolean :agreed_to_waivers
      t.boolean :email_waivers

      t.timestamps
    end
  end
end
