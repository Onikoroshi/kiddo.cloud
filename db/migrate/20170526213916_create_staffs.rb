class CreateStaffs < ActiveRecord::Migration[5.1]
  def change
    create_table :staffs do |t|
      t.references :user, index: true

      t.timestamps
    end
  end
end
