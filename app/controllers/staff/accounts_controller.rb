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
    @location_id = params[:location_id]
    target_location = Location.find_by(id: @location_id)
    target_location = @locations.first if !current_user.super_admin? && !@locations.include?(target_location)

    @show_unregistered = params["show_unregistered"].present?

    @accounts = Account.includes(:parents).where(center: @center).by_location(target_location)
    @accounts = @show_unregistered ? @accounts.where.not(signup_complete: true) : @accounts.where(signup_complete: true)
    @accounts = @accounts.distinct
  end
end
