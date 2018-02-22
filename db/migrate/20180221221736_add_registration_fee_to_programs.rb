class AddRegistrationFeeToPrograms < ActiveRecord::Migration[5.1]
  def change
    add_column :programs, :registration_fee, :float
  end
end
