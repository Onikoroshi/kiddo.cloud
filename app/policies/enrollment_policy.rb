class EnrollmentPolicy < ApplicationPolicy
  alias_method :enrollment, :record

  def manage?
    user.super_admin?
  end

  alias_method :edit?, :manage?
  alias_method :update?, :manage?
end
