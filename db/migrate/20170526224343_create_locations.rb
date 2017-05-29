class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :locations do |t|
      t.references :center, index: true
      t.string :name

      t.timestamps
    end
  end
end
