class Parent < ApplicationRecord
  belongs_to :user
  has_many :children_parents
  has_many :children, through: :children_parents
end
