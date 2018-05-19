class Staff::AccountsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :set_collection, except: :show

  # GET /account/dashboards/1
  def index
    @accounts = @accounts.page(params[:page])
                .per(50)
  end

  def export_to_csv
    send_data @accounts.to_csv
  end

  def show
    @account = Account.find(params[:id])
  end

  private

  def set_collection
    @locations = current_user.manageable_locations
    @location_id = params[:location_id]
    target_location = Location.find_by(id: @location_id)
    target_location = @locations.first if !current_user.super_admin? && !@locations.include?(target_location)

    @accounts = Account
                .includes(:parents)
                .where(center: @center)
                .where(signup_complete: true)
                .by_location(target_location).distinct
  end
end
