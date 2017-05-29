class Core < ApplicationRecord
  belongs_to :center
  has_many :parents
  has_many :emergency_contacts, dependent: :destroy
end
