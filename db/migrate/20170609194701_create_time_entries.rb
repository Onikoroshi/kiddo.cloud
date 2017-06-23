class CreateTimeEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :time_entries do |t|
      t.references :location, index: true
      t.timestamp :time
      t.string :record_type
      t.references :time_recordable, polymorphic: true, index: {:name => "index_recordable_id_type"}
      t.timestamps
    end
  end
end
