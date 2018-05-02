class Staff::AnnouncementsController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!
  before_action :authorize_multiple, only: :index
  before_action :build_single, only: [:new, :create]
  before_action :find_single, only: [:show, :edit, :update, :destroy]
  before_action :authorize_single, except: :index
  before_action :build_payment_offsets, only: [:new, :edit]

  def index
    set_collection
    @announcements = @announcements.page(params[:page]).per(50)
  end

  def new
  end

  def create
    if @announcement.save
      redirect_to staff_announcements_path, notice: "Announcement successfully created."
    else
      build_payment_offsets
      render "new"
    end
  end

  def edit
  end

  def update
    if @announcement.update_attributes(permitted_params)
      redirect_to staff_announcements_path, notice: "Announcement successfully updated."
    else
      build_payment_offsets
      render "edit"
    end
  end

  def destroy
    @announcement.destroy
    redirect_to staff_announcements_path, notice: "Announcement completely removed."
  end

  private

  def authorize_multiple
    authorize Announcement
  end

  def authorize_single
    authorize @announcement
  end

  def set_collection
    @announcements = Announcement.all
  end

  def build_single
    @announcement = Announcement.new(permitted_params)
  end

  def find_single
    @announcement = Announcement.find(params[:id])
  end

  def build_payment_offsets
    @payment_offsets = PaymentOffsetPresenter.build(-15, 14)
  end

  def permitted_params
    @permitted_params ||= params[:announcement].present? ? params.require(:announcement).permit(:program_id, :message) : {}
  end
end
