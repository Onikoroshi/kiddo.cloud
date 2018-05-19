class Staff::StaffController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :authorize_multiple, only: :index
  before_action :build_single, only: [:new, :create]
  before_action :find_single, only: [:show, :edit, :update, :destroy]
  before_action :authorize_single, except: :index

  # GET /account/dashboards/1
  def index
    @staff = Staff
             .all
             .includes(:user)
             .order(created_at: :desc)
             .page(params[:page])
             .per(50)
  end

  def new
  end

  def edit
  end

  def create
    if @staff.save
      unless policy(@staff).super_manage?
        @staff.user.roles << Role.find_by(name: "staff")
      end
      @staff.user.update_attributes(center: @center)
      redirect_to staff_staff_index_path, notice: "Staff member was successfully created."
    else
      render action: "new"
    end
  end

  # PATCH/PUT /interviews/1
  def update
    if @staff.update(permitted_params)
      redirect_to staff_staff_index_path, notice: 'Staff member was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /interviews/1
  def destroy
    @staff.destroy
    redirect_to staff_staff_index_path, notice: 'Staff was successfully removed.'
  end

  private

  def authorize_multiple
    authorize Staff
  end

  def authorize_single
    authorize @staff
  end

  def set_collection
    @staff = Staff.all
    .includes(:user)
    .order(created_at: :desc)
    .page(params[:page])
    .per(50)
  end

  def build_single
    @staff = Staff.new(permitted_params)
    @staff.build_user if @staff.user.blank?
    @staff.locations.build if @staff.locations.blank?
  end

  def find_single
    @staff = Staff.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def permitted_params
    user_attributes = [:id, :email, :first_name, :last_name, :password, :password_confirmation]
    ap user_attributes
    user_attributes += [role_ids: []] if policy(Staff).super_manage?
    ap user_attributes
    @permitted_params ||= params[:staff].present? ? params.require(:staff).permit(user_attributes: user_attributes, location_ids: []) : {}
  end
end
