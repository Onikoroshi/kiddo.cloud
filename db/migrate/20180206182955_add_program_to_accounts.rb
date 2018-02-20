class AddProgramToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_reference :accounts, :program, foreign_key: true
  end
end
