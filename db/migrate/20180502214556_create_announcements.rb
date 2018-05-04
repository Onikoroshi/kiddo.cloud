class CreateAnnouncements < ActiveRecord::Migration[5.1]
  def change
    create_table :announcements do |t|
      t.references :program, foreign_key: true
      t.text :message

      t.timestamps
    end
  end
end
