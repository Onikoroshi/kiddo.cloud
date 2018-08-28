class ProgramLocation < ApplicationRecord
  belongs_to :program
  belongs_to :location

  scope :available, -> { where(available: true) }
end
