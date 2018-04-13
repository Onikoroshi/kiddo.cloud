class AddDeadToEnrollments < ActiveRecord::Migration[5.1]
  def change
    add_column :enrollments, :dead, :boolean, default: false
  end
end
