class AddProgramTypeToPrograms < ActiveRecord::Migration[5.1]
  def change
    add_column :programs, :program_type, :string
  end
end
