class Center < ApplicationRecord
  has_many :accounts, dependent: :destroy
  has_many :users
  has_many :locations, dependent: :destroy
end


