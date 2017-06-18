class Child::AttendanceDisplayController < ApplicationController
  before_action :guard_center!

  # GET /interviews
  def index
  end

end