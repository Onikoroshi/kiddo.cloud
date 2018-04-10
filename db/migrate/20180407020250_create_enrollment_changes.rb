class CreateEnrollmentChanges < ActiveRecord::Migration[5.1]
  def change
    create_table :enrollment_changes do |t|
      t.references :account, foreign_key: true
      t.references :enrollment, foreign_key: true
      t.boolean :requires_refund
      t.boolean :requires_fee
      t.boolean :applied, default: false
      t.text :description
      t.float :amount
      t.jsonb :data

      t.timestamps
    end
  end
end
