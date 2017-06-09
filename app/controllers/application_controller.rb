class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout :get_layout

  before_action :set_center
  before_action :configure_permitted_parameters, if: :devise_controller?

  def set_center
    @center = Center.find_by(subdomain: request.subdomain) if (request.subdomain.present? && !["www", "admin"].include?(request.subdomain))
  end

  # Add to any controller to require multitenancy. You would leave this out of controllers that manage pages like "team"
  # or "about": pages that pertain to the whole application and not just a single center.
  def require_center!
    redirect_to root_url(subdomain: "wwww") if !@center.present?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation, center_attributes: [:subdomain]])
  end

  def after_sign_in_path_for(resource)
    return root_url unless user_signed_in?

    if current_user.present? && current_user.roles.count == 0
      sign_out(resource)
      flash.discard(:notice)
      flash[:error] = "Sign in unsuccessful. You do not appear to have the necessary permissions."
      return new_user_session_url
    end

    stored_location_for(resource) || Receptionist.new(resource, @center).direct
  end

  def get_layout
    @center.present? ? @center.name.parameterize.underscore : "Application"
  end

end
