class Location < ApplicationRecord
  belongs_to :center
  has_one :address, as: :addressable
end
