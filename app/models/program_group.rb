class ProgramGroup < ApplicationRecord
  belongs_to :center

  has_many :programs

  def can_destroy?
    true
  end
end
