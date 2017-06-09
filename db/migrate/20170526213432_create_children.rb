class CreateChildren < ActiveRecord::Migration[5.1]
  def change
    create_table :children do |t|
      t.references :account, index: true
      t.references :parent, index: true
      t.string :first_name
      t.string :last_name
      t.string :grade_entering
      t.date :birthdate
      t.text :additional_info
      t.string :gender

      t.timestamps
    end
  end
end
