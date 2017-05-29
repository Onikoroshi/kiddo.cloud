class Core < ApplicationRecord
  belongs_to :center
  has_many :parents
end
