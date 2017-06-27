class ChildLocation < ApplicationRecord
  belongs_to :child
  belongs_to :location
end