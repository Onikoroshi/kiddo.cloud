class RemoveShortCodeFromPlans < ActiveRecord::Migration[5.1]
  def change
    remove_column :plans, :short_code, :string
  end
end
