class Receptionist
  include Rails.application.routes.url_helpers

  def initialize(current_user)
    @current_user = current_user
  end

  # Show the intermediate "choose your path" page if the user has more
  # than one role. Otherwise, direct to the page for your role.
  def direct
    if @current_user.nil?
      new_user_session_path
    elsif @current_user.roles.count > 1
      receptionist_index_path
    else
      direct_by_role(@current_user.roles.first)
    end
  end

  def direct_by_role(role)
    return root_path unless role.present?

    case role.name
    when "super_admin"
      root_path
    when "btv_admin"
      admin_dashboard_admin_path
    when "wu_admin"
      root_path
    end
  end

end
