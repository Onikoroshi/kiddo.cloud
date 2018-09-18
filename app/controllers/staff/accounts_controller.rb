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

    unless params[:search].blank?
      @program_id = ""
      @program = nil
      @location_id = ""
      @location = nil

      @accounts = Account.includes(:parents).joins(:user).where("lower(users.email) ILIKE ?", "%#{params[:search].to_s.downcase}%")
    else
      @program_id = params[:program_id]
      @program = Program.find_by(id: @program_id)
      @program = @programs.first if !current_user.super_admin? && !@programs.include?(@program)
      @program_id = @program.id if @program.present?

      @locations = Location.where(id: (@locations.pluck(:id) & @program.locations.pluck(:id))) if @program.present?

      @location_id = params[:location_id]
      @location = Location.find_by(id: @location_id)
      @location = @locations.first if !current_user.super_admin? && !@locations.include?(@location)
      @location_id = @location.id if @location.present?

      @show_unregistered = params["show_unregistered"].present?

      @accounts = Account.includes(:parents).where(center: @center).by_program(@program).by_location(@location)
      @accounts = @show_unregistered ? @accounts.where.not(signup_complete: true) : @accounts.where(signup_complete: true)
    end

    @accounts = @accounts.distinct
  end
end
