class AddFiltersToAnnouncements < ActiveRecord::Migration[5.1]
  def change
    add_reference :announcements, :location, foreign_key: true
    add_column :announcements, :plan_type, :string
  end
end
