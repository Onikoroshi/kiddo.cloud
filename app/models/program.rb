class Program < ApplicationRecord
  belongs_to :center
  has_many :plans
end
