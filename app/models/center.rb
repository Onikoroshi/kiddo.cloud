class Center < ApplicationRecord
  has_many :cores, dependent: :destroy
  has_many :users
  has_many :locations, dependent: :destroy
end


