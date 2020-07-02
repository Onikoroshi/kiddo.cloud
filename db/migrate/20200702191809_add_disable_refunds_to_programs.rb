class AddDisableRefundsToPrograms < ActiveRecord::Migration[5.1]
  def change
    add_column :programs, :disable_refunds, :boolean, default: false
  end
end
