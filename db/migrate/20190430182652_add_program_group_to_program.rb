class AddProgramGroupToProgram < ActiveRecord::Migration[5.1]
  def change
    add_reference :programs, :program_group, foreign_key: false
  end
end
