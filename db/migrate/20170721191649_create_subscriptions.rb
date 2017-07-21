class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
      t.references :account, foreign_key: true
      t.string :gateway_id

      t.timestamps
    end
  end
end
