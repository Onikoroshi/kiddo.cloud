class CreateLateCheckinNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :late_checkin_notifications do |t|
      t.references :account
      t.references :child
      t.string :sent_at

      t.timestamps
    end
  end
end
