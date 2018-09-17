class CreateHolidays < ActiveRecord::Migration[5.1]
  def change
    create_table :holidays do |t|
      t.references :program, foreign_key: true
      t.date :holidate

      t.timestamps
    end
  end
end
