class Staff::AccountsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :set_collection, except: :show

  # GET /account/dashboards/1
  def index
    authorize Account

    @accounts = @accounts.page(params[:page]).per(50)
  end

  def export_to_csv
    send_data @accounts.to_csv
  end

  def show
    @account = Account.find(params[:id])

    authorize @account
  end

  private

  def set_collection
    @locations = current_user.manageable_locations
    @programs = @locations.programs

    @program = Program.find_by(id: params[:program_id]) || @center.current_program
    @program = @programs.first unless @programs.include?(@program)

    @locations = Location.where(id: (@locations.pluck(:id) & @program.locations.pluck(:id)))

    @location_id = params[:location_id]
    @location = Location.find_by(id: @location_id)
    @location = @locations.first if !current_user.super_admin? && !@locations.include?(@location)

    @show_unregistered = params["show_unregistered"].present?

    @accounts = Account.includes(:parents).where(center: @center).by_program(@program).by_location(@location)
    @accounts = @show_unregistered ? @accounts.where.not(signup_complete: true) : @accounts.where(signup_complete: true)
    @accounts = @accounts.distinct
  end
end
