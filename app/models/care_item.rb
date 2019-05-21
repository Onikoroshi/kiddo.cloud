class CareItem < ApplicationRecord
  belongs_to :child

  validates_uniqueness_of :child_id, uniqueness: {scope: :name}

  scope :active, -> { where(active: true) }
end
