class CareItem < ApplicationRecord
  belongs_to :child

  scope :active, -> { where(active: true) }
end
