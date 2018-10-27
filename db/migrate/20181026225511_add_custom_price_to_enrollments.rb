class AddCustomPriceToEnrollments < ActiveRecord::Migration[5.1]
  def change
    add_column :enrollments, :custom_price, :float
  end
end
