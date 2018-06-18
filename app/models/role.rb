class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  validates_presence_of :name
  validates_uniqueness_of :name

  scope :staff_types, -> { where.not(name: "parent") }

  def display_name
    name.humanize
  end
end
