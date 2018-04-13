class Staff::TransactionsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!

  def index
    @program = Program.find_by(id: params[:program_id]) || @center.current_program
    @location = Location.find_by(id: params[:location_id])
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
