class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.references :user, foreign_key: true
      t.references :center, foreign_key: true
      t.string :last_registration_step_completed
      t.string :signature
      t.boolean :waiver_agreement, default: false
      t.boolean :mail_agreements, default: true
      t.boolean :medical_waiver_agreement, default: false
      t.boolean :signup_complete, default: false
      t.timestamps
    end
  end
end
