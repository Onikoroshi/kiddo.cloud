class Program < ApplicationRecord
  belongs_to :center
  has_many :plans
  has_many :drop_ins
end
