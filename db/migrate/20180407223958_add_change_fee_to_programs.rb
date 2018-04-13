class AddChangeFeeToPrograms < ActiveRecord::Migration[5.1]
  def change
    add_column :programs, :change_fee, :float
  end
end
