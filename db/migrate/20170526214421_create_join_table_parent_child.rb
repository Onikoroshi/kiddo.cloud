class CreateJoinTableParentChild < ActiveRecord::Migration[5.1]
  def change
    create_join_table :parents, :children do |t|
      t.index [:parent_id, :child_id]
      t.index [:child_id, :parent_id]
    end
  end
end
