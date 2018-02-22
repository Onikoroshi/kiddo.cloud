class Parent < ApplicationRecord
  belongs_to :account
  belongs_to :user
  has_and_belongs_to_many :children
  has_one :address, as: :addressable

  def full_name
    "#{first_name} #{last_name}"
  end
end
