class RemoveShortCodeFromPrograms < ActiveRecord::Migration[5.1]
  def change
    remove_column :programs, :short_code, :string
  end
end
