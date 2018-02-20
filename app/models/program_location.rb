class ProgramLocation < ApplicationRecord
  belongs_to :program
  belongs_to :location
end
