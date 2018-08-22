class TimeEntryPolicy < ApplicationPolicy
  alias_method :time_entry, :record

  def view?
    user.role?("super_admin", "director")
  end

  alias_method :index?, :view?
  alias_method :export_to_csv?, :view?
  alias_method :ratio_report?, :view?
  alias_method :ratio_csv?, :view?

  def manage?
    user.super_admin?
  end

  alias_method :new?, :manage?
  alias_method :create?, :manage?
  alias_method :edit?, :manage?
  alias_method :update?, :manage?
  alias_method :destroy?, :manage?
end
