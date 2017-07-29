class CreatePrograms < ActiveRecord::Migration[5.1]
  def change
    create_table :programs do |t|
      t.references :center, foreign_key: true
      t.string :short_code
      t.string :name
      t.date :starts_at
      t.date :ends_at

      t.timestamps
    end
  end
end
