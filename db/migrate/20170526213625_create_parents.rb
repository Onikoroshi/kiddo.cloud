class CreateParents < ActiveRecord::Migration[5.1]
  def change
    create_table :parents do |t|
      t.references :user, index: true
      t.references :account, index: true
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.boolean :primary, default: false
      t.boolean :secondary, default: false

      t.timestamps
    end
  end
end
