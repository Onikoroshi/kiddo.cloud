class CenterDashboardPolicy < Struct.new(:user, :dashboard)

  def show?
    user.role?(:super_admin, :staff, :director)
  end

end
