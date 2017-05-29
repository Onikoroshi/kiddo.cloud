class CreateCenters < ActiveRecord::Migration[5.1]
  def change
    create_table :centers do |t|
      t.string :name
      t.string :subdomain
      t.integer :user_id

      t.timestamps
    end
  end
end
