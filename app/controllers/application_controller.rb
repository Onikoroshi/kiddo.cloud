class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout :get_layout
  include Pundit

  before_action :logout_not_signed_in

  before_action :set_raven_context
  before_action :set_center
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def set_center
    @center = Center.first
  end

  # Add to any controller to require multitenancy. You would leave this out of controllers that manage pages like "team"
  # or "about": pages that pertain to the whole application and not just a single center.
  def guard_center!
    checkpoint = CenterCheckPoint.new(center: @center, user: current_user)
    if !checkpoint.passes?
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to root_url
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation, center_attributes: [:subdomain]])
  end

  def after_sign_in_path_for(resource)
    puts "in after sign in path"
    return new_user_session_url unless user_signed_in?
    return handle_signout if user_exists_without_roles? || @center.nil? # center could be nil if session expires but user still available
    stored_location_for(resource) || Receptionist.new(resource, @center).direct
  end

  def get_layout
    @center.present? ? @center.name.parameterize.underscore : "application"
  end

  def find_registering_program
    @program = Program.find_by(id: params[:program_id])

    if @account.present? && @program.present?
      @account.update_attribute(:program, @program)
    end

    if @account.present? && @program.blank?
      @program = @account.program
    end

    @program = @center.current_program if @center.present? && @program.blank?
  end

  private

  def logout_not_signed_in
    allowed_paths = [
      root_path,
      new_user_session_path,
      new_user_registration_path,
      new_user_password_path,
      user_password_path,
      edit_user_password_path
    ]
    redirect_to root_path and return if current_user.blank? && !allowed_paths.include?(request.path)
  end

  def user_exists_without_roles?
    current_user.present? && current_user.roles.count == 0
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to request.referrer || root_url
  end

  def handle_signout
    sign_out(resource)
    flash.discard(:notice)
    flash[:error] = "Sign in unsuccessful."
    new_user_session_url
  end

  def set_raven_context
    Raven.user_context(id: current_user.try(:id), email: current_user.try(:email))
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  rescue => exception
    puts exception
  end

  def set_layout_by_role
    if current_user.present?
      if current_user.parent?
        if @account.present? && @account.signup_complete?
          "dkk_customer_dashboard"
        else
          get_layout
        end
      else
        "dkk_staff_dashboard"
      end
    else
      get_layout
    end
  end
end
