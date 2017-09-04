class Users::LegacyRegistrationsController < Devise::RegistrationsController
  layout :evaluate_layout
  prepend_before_action :set_center

  def set_center
    subdomain = request.subdomain.include?("staging") ? "daviskidsklub" : request.subdomain
    @center = Center.find_by(subdomain: subdomain) if (subdomain.present? && !["www", "admin"].include?(subdomain))

    if !@center.present?
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_url(subdomain: "www"))
    end
  end

  # POST /resource
  def create
    build_resource(sign_up_params)

    if !legacy_authenticatable?
      flash[:warning] = "Please check your existing email address is correct."
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource, location: new_legacy_user_registration_path
    else

      email = params[:legacy_user][:email]
      email = email.downcase
      legacy_user = LegacyUser.where(email: email).first
      legacy_user.update_attributes(reregistered: true) if legacy_user.present?

      @center.users << resource if resource.save # Register user for center

      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(:user, resource)
          AccountBuilder.new(resource, @center).build
          resource.update_attributes(legacy: true)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end
  end

  def after_sign_up_path_for(resource)
    account_step_path(resource.parent.account, :parents)
  end

  def legacy_authenticatable?
    active = false
    email = params[:legacy_user][:email]
    email = email.downcase
    if LegacyUser.where(email: email).exists? && !User.where(email: email).exists?
      active = true
    end
    active
  end

  protected

    def after_update_path_for(resource)
      flash[:notice] = "Account succesfully updated"
      account_dashboard_path(current_user.account)
    end

  private

    # i.e. 'davis_kids_klub' or 'dkk_customer_dashboard'
    def evaluate_layout
      layout_name = @center.name.parameterize.underscore
      if ["edit", "update"].include?(action_name)
        layout_name = "dkk_customer_dashboard"
      end
      layout_name
    end
end
