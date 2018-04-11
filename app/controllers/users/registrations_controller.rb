class Users::RegistrationsController < Devise::RegistrationsController
  layout :evaluate_layout

  # POST /resource
  def create
    build_resource(sign_up_params)
    @center.users << resource if resource.save #Register user for center

    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        program = Program.find_by(short_code: params[:program])
        AccountBuilder.new(resource, @center, program).build
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

  def edit
    @account = current_user.account
    super
  end

  def update
    @account = current_user.account
    super
  end

  def after_sign_up_path_for(resource)
    account_step_path(resource.parent.account, :parents)
  end

  protected

    def after_update_path_for(resource)
      flash[:notice] = "Account succesfully updated"
      root_path
    end

  private

    # i.e. 'davis_kids_klub' or 'dkk_customer_dashboard'
    def evaluate_layout
      layout_name = @center.name.parameterize.underscore
      layout_name
    end
end
