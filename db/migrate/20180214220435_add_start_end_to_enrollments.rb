class AddStartEndToEnrollments < ActiveRecord::Migration[5.1]
  def change
    add_column :enrollments, :starts_at, :date
    add_column :enrollments, :ends_at, :date
  end
end
