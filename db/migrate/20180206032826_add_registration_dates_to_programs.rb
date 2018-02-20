class AddRegistrationDatesToPrograms < ActiveRecord::Migration[5.1]
  def change
    add_column :programs, :registration_opens, :date
    add_column :programs, :registration_closes, :date
  end
end
