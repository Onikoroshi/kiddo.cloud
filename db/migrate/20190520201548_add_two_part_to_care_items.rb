class AddTwoPartToCareItems < ActiveRecord::Migration[5.1]
  def change
    add_column :care_items, :two_part, :boolean, default: false
    add_column :care_items, :three_part, :boolean, default: false
    add_column :care_items, :required, :boolean, default: true
  end
end
