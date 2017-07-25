class ProgramPlan < ApplicationRecord
  belongs_to :program
  belongs_to :child
end
