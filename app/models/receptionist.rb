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
    when "super_admin", "director", "staff"
      staff_dashboard_path
    when "parent"
      if current_user.account.signup_complete?
        account_dashboard_path(current_user.account)
      else
        last_step = current_user.account.last_registration_step_completed
        last_step = last_step.blank? ? :parents : last_step.to_sym
        account_step_path(current_user.account, SignupStep.find(last_step.to_sym).next_step)
      end
    end
  end

end
