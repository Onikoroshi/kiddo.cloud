class Child < ApplicationRecord
  has_many :children_parents
  has_many :parents, through: :children_parents
end
