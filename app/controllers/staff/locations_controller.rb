class Staff::LocationsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :authorize_multiple, only: :index
  before_action :build_single, only: [:new, :create]
  before_action :find_single, only: [:show, :edit, :update, :destroy]
  before_action :authorize_single, except: :index
  before_action :build_variables, only: [:show, :edit]

  def index
    set_collection
    @locations = @locations.page(params[:page]).per(50)
  end

  def new
  end

  def create
    if @location.save
      update_availables
      redirect_to staff_locations_path, notice: "Location successfully created."
    else
      render "new"
    end
  end

  def edit
  end

  def update
    if @location.update_attributes(permitted_params)
      update_availables
      redirect_to staff_locations_path, notice: "Location successfully updated."
    else
      render "edit"
    end
  end

  def destroy
    if @location.can_destroy?
      @location.destroy
      redirect_to staff_locations_path, notice: "Location completely removed."
    else
      redirect_to staff_locations_path, notice: "Only Locations with no enrollments or transactions can be removed."
    end
  end

  private

  def update_availables
    @location.program_locations.each do |prog_loc|
      prog_loc.update_attribute(:available, params["availables"].present? && params["availables"][prog_loc.program_id.to_s].present? && params["availables"][prog_loc.program_id.to_s] == "true")
    end
  end

  def authorize_multiple
    authorize Location
  end

  def authorize_single
    authorize @location
  end

  def set_collection
    @locations = Location.all
  end

  def build_single
    @location = Location.new(permitted_params)
  end

  def find_single
    @location = Location.find(params[:id])
  end

  def build_variables
    @programs = Program.all.reorder("name ASC")
  end

  def permitted_params
    @permitted_params ||= params[:location].present? ? params.require(:location).permit(:name, program_ids: []) : {}
  end
end
