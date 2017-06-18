class AttendanceRouterController < ApplicationController
  before_action :guard_center!

  def show
   authorize :center_dashboard, :show?
  end

end