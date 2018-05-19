class Staff::TimeEntriesController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :find_staff
  before_action :authorize_multiple, only: :index
  before_action :build_single, only: [:new, :create]
  before_action :find_single, only: [:show, :edit, :update, :destroy]
  before_action :authorize_single, except: :index

  def index
    set_collection
    @time_entries = @time_entries.page(params[:page]).per(50)
  end

  def new
  end

  def create
    if @time_entry.save
      redirect_to staff_time_entries_path(staff_id: @staff.id), notice: "Time Entry successfully created."
    else
      render "new"
    end
  end

  def edit
  end

  def update
    if @time_entry.update_attributes(permitted_params)
      redirect_to staff_time_entries_path(staff_id: @staff.id), notice: "Time Entry successfully updated."
    else
      render "edit"
    end
  end

  def destroy
    @time_entry.destroy
    redirect_to staff_time_entries_path(staff_id: @staff.id), notice: "Time Entry completely removed."
  end

  private

  def find_staff
    @staff = Staff.find(params[:staff_id])
  end

  def authorize_multiple
    authorize TimeEntry
  end

  def authorize_single
    authorize @time_entry
  end

  def set_collection
    @time_entries = @staff.time_entries.order("time DESC")
  end

  def build_single
    @time_entry = TimeEntry.new(permitted_params)
  end

  def find_single
    @time_entry = TimeEntry.find(params[:id])
  end

  def permitted_params
    @permitted_params ||= params[:time_entry].present? ? params.require(:time_entry).permit(:time_recordable_id, :time_recordable_type, :location_id, :time, :record_type) : {}
  end
end
