class CreateStaff < ActiveRecord::Migration[5.1]
  def change
    create_table :staff do |t|
      t.references :user, index: true

      t.timestamps
    end
  end
end
