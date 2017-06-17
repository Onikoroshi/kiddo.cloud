class CenterDashboardPolicy < Struct.new(:user, :dashboard)

  def show?
    user.director?
  end

end