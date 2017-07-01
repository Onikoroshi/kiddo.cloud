class Account < ApplicationRecord
  belongs_to :center
  has_many :parents
  has_many :children
  has_many :emergency_contacts, dependent: :destroy

  def primary_parent
    parents.where(primary: true).first
  end

end
