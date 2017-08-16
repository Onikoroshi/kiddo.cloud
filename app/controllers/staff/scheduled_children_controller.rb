class Staff::ScheduledChildrenController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!

  def index
    @transactions = Transaction
                    .includes(:account)
                    .where(program: @center.current_program)
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(50)
  end

  def show; end
end
