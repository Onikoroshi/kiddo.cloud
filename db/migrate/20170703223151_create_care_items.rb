class CreateCareItems < ActiveRecord::Migration[5.1]
  def change
    create_table :care_items do |t|
      t.references :child, foreign_key: true
      t.string :name
      t.boolean :active
      t.text :explanation

      t.timestamps
    end
  end
end
