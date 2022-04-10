class AddWaivePaymentInformationToPrograms < ActiveRecord::Migration[5.1]
  def change
    add_column :programs, :waive_payment_information, :boolean, default: false
  end
end
