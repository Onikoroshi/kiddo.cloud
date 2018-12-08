class Staff::AccountsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :set_collection, except: :show

  # GET /account/dashboards/1
  def index
    authorize Account

    @all_accounts = @accounts
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
    ap "locations: #{@locations.pluck(:id)}"
    @programs = @locations.programs
    ap "programs: #{@programs.pluck(:id)}"

    unless params[:search].blank?
      ap "search not blank"
      @program_id = ""
      @program = nil
      @location_id = ""
      @location = nil

      target = "%#{params[:search].to_s.downcase.gsub(" ", "")}%"
      @accounts = Account.includes(:parents).where("accounts.search_field ILIKE ?", target)
    else
      ap "search blank"
      @program_id = params[:program_id]
      ap "initial program id: #{@program_id}"
      @program = Program.find_by(id: @program_id)
      ap "initial program: #{@program.present? ? @program.id : "none"}"
      ap "current user super_admin? #{current_user.super_admin?}"
      ap "programs include current? #{@programs.include?(@program)}"
      @program = @programs.first if !current_user.super_admin? && !@programs.include?(@program)
      ap "final program: #{@program.present? ? @program.id : "none"}"
      @program_id = @program.id if @program.present?
      ap "final program id: #{@program_id}"

      @locations = Location.where(id: (@locations.pluck(:id) & @program.locations.pluck(:id))) if @program.present?
      ap "final locations: #{@locations.pluck(:id)}"

      @location_id = params[:location_id]
      ap "initial location id: #{@location_id}"
      @location = Location.find_by(id: @location_id)
      ap "initial location: #{@location.present? ? @location.id : "none"}"
      ap "current user super_admin? #{current_user.super_admin?}"
      ap "locations include current? #{@locations.include?(@location)}"
      @location = @locations.first if !current_user.super_admin? && !@locations.include?(@location)
      ap "final location: #{@location.present? ? @location.id : "none"}"
      @location_id = @location.id if @location.present?
      ap "final location id: #{@location_id}"

      @show_unregistered = params["show_unregistered"].present?

      @accounts = Account.includes(:parents).where(center: @center).by_program(@program).by_location(@location)
      ap "initial accounts: #{@accounts.count}"
      @accounts = @show_unregistered ? @accounts.where.not(signup_complete: true) : @accounts.where(signup_complete: true)
      ap "final accounts: #{@accounts.count}"
    end

    @accounts = @accounts.distinct
    ap "distinct accounts: #{@accounts.count}"
    @accounts
  end
end
