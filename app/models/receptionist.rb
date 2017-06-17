class Receptionist
  include Rails.application.routes.url_helpers

  attr_reader :current_user, :center
  def initialize(current_user, center)
    @current_user = current_user
    @center = center
  end

  # Show the intermediate "choose your path" page if the user has more
  # than one role. Otherwise, direct to the page for your role.
  def direct
    if @current_user.nil? || @center.nil?
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
    when "root"
      root_path
    when "director"
      attendance_router_path
    when "wu_admin"
      root_path
    end
  end

end
