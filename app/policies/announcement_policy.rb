class AnnouncementPolicy < ApplicationPolicy
  alias_method :announcement, :record

  def manage?
    user.role?("super_admin")
  end

  alias_method :index?, :manage?
  alias_method :new?, :manage?
  alias_method :create?, :manage?
  alias_method :edit?, :manage?
  alias_method :update?, :manage?
  alias_method :destroy?, :manage?
end
