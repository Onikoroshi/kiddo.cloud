class Staff::TransactionsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!

  def index
    @locations = current_user.manageable_locations
    @programs = @locations.programs

    @program = Program.find_by(id: params[:program_id]) || @center.current_program
    @program = @programs.first unless @programs.include?(@program)

    @locations = Location.where(id: (@locations.pluck(:id) & @program.locations.pluck(:id)))

    @location = Location.find_by(id: params[:location_id])
    @location = @locations.first if !current_user.super_admin? && !@locations.include?(@location)
    @location_id = @location.present? ? @location.id : ""

    @accounts = Account
                .includes(:parents)
                .by_program(@program)
                .by_location(@location)
                .page(params[:page])
                .per(50)
  end

  def show; end
end
