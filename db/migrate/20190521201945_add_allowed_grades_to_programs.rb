class AddAllowedGradesToPrograms < ActiveRecord::Migration[5.1]
  def change
    add_column :programs, :allowed_grades, :jsonb, default: []
  end
end
