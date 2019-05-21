class CareItem < ApplicationRecord
  belongs_to :child

  validates :child_id, uniqueness: {scope: :name}

  scope :active, -> { where(active: true) }
end
