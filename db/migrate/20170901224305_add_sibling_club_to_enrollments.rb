class AddSiblingClubToEnrollments < ActiveRecord::Migration[5.1]
  def change
    add_column :enrollments, :sibling_club, :boolean, default: false
  end
end
