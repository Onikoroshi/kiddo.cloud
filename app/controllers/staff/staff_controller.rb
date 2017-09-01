class Staff::StaffController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :set_staff, only: [:show, :edit, :update, :destroy]

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
    @staff = Staff.new(user: User.new)
    @staff.locations.build
  end

  def edit; end

  def create
    @staff = Staff.new(staff_params)
    if @staff.save
      @staff.user.roles << Role.find_by(name: "staff")
      @staff.user.update_attributes(center: @center)
      redirect_to staff_staff_index_path, notice: "Staff member was successfully created."
    else
      render action: "new"
    end
  end

  # PATCH/PUT /interviews/1
  def update
    if @staff.update(staff_params)
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

  # Use callbacks to share common setup or constraints between actions.
  def set_staff
    @staff = Staff.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def staff_params
    permitted_attributes = [
      :location_ids,
      user_attributes: [
        :id,
        :email,
        :first_name,
        :last_name,
        :password,
        :password_confirmation
      ],
    ]
    params.require(:staff).permit(permitted_attributes)
  end
end
