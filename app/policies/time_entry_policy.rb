class TimeEntryPolicy < ApplicationPolicy
  alias_method :time_entry, :record

  def view?
    user.role?("super_admin", "director")
  end

  alias_method :index?, :view?

  def manage?
    user.role?("super_admin")
  end

  alias_method :new?, :manage?
  alias_method :create?, :manage?
  alias_method :edit?, :manage?
  alias_method :update?, :manage?
  alias_method :destroy?, :manage?
end
