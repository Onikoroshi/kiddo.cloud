class Users::RegistrationsController < Devise::RegistrationsController
  layout :evaluate_layout

  before_action :find_program

  # POST /resource
  def create
    ap sign_up_params
    build_resource(sign_up_params)
    @center.users << resource if resource.save #Register user for center
    ap resource

    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        AccountBuilder.new(resource, @center, @program).build
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      found_user = User.find_by(email: resource.email)
      if found_user.present? && found_user.parent? && found_user.valid_password?(sign_up_params[:password])
        set_flash_message! :notice, :existing_account
        sign_in(found_user)
        respond_with found_user, location: after_sign_in_path_for(found_user)
        return
      end

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

  def find_program
    @program = Program.find_by(id: params[:program_id]) || @center.current_program
  end

  # i.e. 'davis_kids_klub' or 'dkk_customer_dashboard'
  def evaluate_layout
    layout_name = @center.name.parameterize.underscore
    layout_name
  end
end
