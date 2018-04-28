class AddDescriptionToEnrollmentTransactions < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column :enrollment_transactions, :description_data, :hstore
    add_index :enrollment_transactions, :description_data, using: :gin
  end
end
