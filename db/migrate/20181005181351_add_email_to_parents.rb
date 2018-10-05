class AddEmailToParents < ActiveRecord::Migration[5.1]
  def change
    add_column :parents, :email, :string
  end
end
