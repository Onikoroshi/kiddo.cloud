class AddPriorityToPrograms < ActiveRecord::Migration[5.1]
  def change
    add_column :programs, :priority, :integer
  end
end
