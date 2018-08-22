class Staff::TimeEntriesController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :find_recordable, except: [:ratio_report, :ratio_csv]
  before_action :authorize_multiple, only: [:index, :export_to_csv, :ratio_report, :ratio_csv]
  before_action :build_single, only: [:new, :create]
  before_action :find_single, only: [:show, :edit, :update, :destroy]
  before_action :authorize_single, except: [:index, :export_to_csv, :ratio_report, :ratio_csv]
  before_action :build_report_data, only: [:ratio_report, :ratio_csv]

  def ratio_report
    @report_hash = @time_entries.ratio_report_hash
  end

  def ratio_csv
    send_data @time_entries.to_ratio_csv, filename: "#{@target_date.stamp("Wednesday, March 5th, 2019")}.csv"
  end

  def index
    set_collection
    @time_entries = @time_entries.page(params[:page]).per(50)
  end

  def export_to_csv
    set_collection
    send_data @time_entries.to_csv, filename: "Time Entries for #{@recordable.full_name}.csv"
  end

  def new
  end

  def create
    if @time_entry.save
      redirect_to staff_time_entries_path(recordable_type: @recordable_type, recordable_id: @recordable.id), notice: "Time Entry successfully created."
    else
      render "new"
    end
  end

  def edit
  end

  def update
    if @time_entry.update_attributes(permitted_params)
      redirect_to staff_time_entries_path(recordable_type: @recordable_type, recordable_id: @recordable.id), notice: "Time Entry successfully updated."
    else
      render "edit"
    end
  end

  def destroy
    @time_entry.destroy
    redirect_to staff_time_entries_path(recordable_type: @recordable_type, recordable_id: @recordable.id), notice: "Time Entry completely removed."
  end

  private

  def find_recordable
    @recordable_type = params[:recordable_type]
    case @recordable_type
    when "Staff"
      @recordable = Staff.find(params[:recordable_id])
    when "Child"
      @recordable = Child.find(params[:recordable_id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def authorize_multiple
    authorize TimeEntry
  end

  def authorize_single
    authorize @time_entry
  end

  def set_collection
    @time_entries = @recordable.time_entries.order("time DESC")
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

  def build_report_data
    @target_date = Time.zone.parse(params[:date].to_s)
    @target_date = @target_date.present? ? @target_date.to_date : Time.zone.today

    @location = Location.find_by_id(params[:location_id])
    @location = Location.first if @location.blank?
    @location_id = @location.id

    @time_entries = TimeEntry.for_date(@target_date).for_location(@location)
  end
end
