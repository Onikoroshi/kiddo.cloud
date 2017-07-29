class DropIn < ApplicationRecord
  belongs_to :account
  belongs_to :child
end
