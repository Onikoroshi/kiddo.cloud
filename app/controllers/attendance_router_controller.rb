class AttendanceRouterController < ApplicationController
  before_action :require_center!

  def show
   authorize :center_dashboard, :show?
  end

end