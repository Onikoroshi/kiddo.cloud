class Child < ApplicationRecord
  belongs_to :account
  has_many :children_parents
  has_many :parents, through: :children_parents
  has_many :time_entries, as: :time_recordable

  def full_name
    "#{first_name} #{last_name}"
  end
end
