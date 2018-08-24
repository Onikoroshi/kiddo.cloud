class StaffPolicy < ApplicationPolicy
  alias_method :staff, :record

  def super_manage?
    user.super_admin?
  end

  alias_method :destroy?, :super_manage?

  def manage?
    return true if user.super_admin?
    return true if !staff.is_a?(Staff) && user.director?
    return false if user.role?("staff", "parent")

    user.director? && (staff.user.blank? || staff.user.roles.blank? || staff.user.roles.map(&:name).include?("staff"))
  end

  alias_method :index?, :manage?
  alias_method :new?, :manage?
  alias_method :create?, :manage?
  alias_method :edit?, :manage?
  alias_method :update?, :manage?
end
