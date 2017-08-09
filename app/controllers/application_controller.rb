class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout :get_layout
  include Pundit

  before_action :set_center
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def set_center
    @center = Center.find_by(subdomain: request.subdomain) if (request.subdomain.present? && !["www", "admin"].include?(request.subdomain))
    if !@center.present?
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_url(subdomain: "www"))
    end
  end

  # Add to any controller to require multitenancy. You would leave this out of controllers that manage pages like "team"
  # or "about": pages that pertain to the whole application and not just a single center.
  def guard_center!
    checkpoint = CenterCheckPoint.new(center: @center, user: current_user)
    if !checkpoint.passes?
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(root_url(subdomain: "www"))
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation, center_attributes: [:subdomain]])
  end

  def after_sign_in_path_for(resource)
    return root_url unless user_signed_in?
    return handle_signout if user_exists_without_roles? || @center.nil? # center could be nil if session expires but user still available
    stored_location_for(resource) || Receptionist.new(resource, @center).direct
  end

  def get_layout
    @center.present? ? @center.name.parameterize.underscore : "application"
  end

  private

  def user_exists_without_roles?
    current_user.present? && current_user.roles.count == 0
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_url(subdomain: "www"))
  end

  def handle_signout
    sign_out(resource)
    flash.discard(:notice)
    flash[:error] = "Sign in unsuccessful."
    new_user_session_url
  end

end
