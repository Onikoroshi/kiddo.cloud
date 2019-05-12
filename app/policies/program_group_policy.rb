class ProgramGroupPolicy < ApplicationPolicy
  alias_method :program_group, :record

  def manage?
    user.super_admin?
  end

  alias_method :index?, :manage?
  alias_method :new?, :manage?
  alias_method :create?, :manage?
  alias_method :edit?, :manage?
  alias_method :update?, :manage?
  alias_method :destroy?, :manage?
end