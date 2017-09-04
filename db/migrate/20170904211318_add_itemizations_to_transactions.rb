class AddItemizationsToTransactions < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column :transactions, :itemizations, :hstore
    add_index :transactions, :itemizations, using: :gin
  end
end
