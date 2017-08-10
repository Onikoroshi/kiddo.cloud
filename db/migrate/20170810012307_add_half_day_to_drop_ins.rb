class AddHalfDayToDropIns < ActiveRecord::Migration[5.1]
  def change
    add_column :drop_ins, :time_slot, :string
  end
end
