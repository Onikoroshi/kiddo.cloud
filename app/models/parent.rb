class Parent < ApplicationRecord
  belongs_to :core
  belongs_to :user
  has_many :children_parents
  has_many :children, through: :children_parents
  has_one :address, as: :addressable

  delegate :first_name, :last_name, to: :user

end
