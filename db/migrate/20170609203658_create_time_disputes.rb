class CreateTimeDisputes < ActiveRecord::Migration[5.1]
  def change
    create_table :time_disputes do |t|
      t.references :location, foreign_key: true
      t.belongs_to :created_by
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.date :date
      t.text :message

      t.timestamps
    end
  end
end
