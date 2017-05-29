class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

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

end
