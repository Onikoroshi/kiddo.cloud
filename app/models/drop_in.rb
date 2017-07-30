class DropIn < ApplicationRecord
  belongs_to :account
  belongs_to :child

  money_column :price

  def wednesday?
    date.wednesday?
  end
end
