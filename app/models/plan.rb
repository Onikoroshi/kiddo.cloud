class Plan < ApplicationRecord
  belongs_to :program

  has_many :enrollments
  has_many :children, through: :enrollments

  has_many :transactions

  money_column :price
end
