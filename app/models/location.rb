class Location < ApplicationRecord
  belongs_to :account
  has_one :address, as: :addressable
end
