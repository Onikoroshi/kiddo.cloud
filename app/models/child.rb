class Child < ApplicationRecord
  belongs_to :core
  has_many :children_parents
  has_many :parents, through: :children_parents
end
