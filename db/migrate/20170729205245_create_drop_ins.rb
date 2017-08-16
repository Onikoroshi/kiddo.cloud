class CreateDropIns < ActiveRecord::Migration[5.1]
  def change
    create_table :drop_ins do |t|
      t.references :account, foreign_key: true
      t.references :program, foreign_key: true
      t.references :child, foreign_key: true
      t.references :location, foreign_key: true
      t.date :date
      t.text :notes
      t.float :price
      t.boolean :paid, default: :false

      t.timestamps
    end
  end
end
