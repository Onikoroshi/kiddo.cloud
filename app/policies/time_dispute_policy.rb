class TimeDisputePolicy < ApplicationPolicy

  def new?
    user.director?
  end

  def create?
    user.director?
  end

end