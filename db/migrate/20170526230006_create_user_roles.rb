class CreateUserRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :user_roles do |t|
      t.references :role, index: true
      t.references :user, index: true
      t.timestamps
    end
  end
end
