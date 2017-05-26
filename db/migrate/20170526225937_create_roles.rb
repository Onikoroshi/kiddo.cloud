class CreateRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :roles do |t|
      t.string :name
      t.string :slug
      t.string :display_name
      t.string :short_description
      t.string :description

      t.timestamps
    end
  end
end
