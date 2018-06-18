class AddPinToStaff < ActiveRecord::Migration[5.1]
  def change
    add_column :staff, :pin_number, :string
  end
end
