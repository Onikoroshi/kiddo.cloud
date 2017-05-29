class ReceptionistController < ApplicationController

  before_filter :redirect_without_multiple_roles

  def index
    @receptionist = Receptionist.new(current_user)
  end

  private

    def redirect_without_multiple_roles
      redirect_to root_path unless user_signed_in? && current_user.active_roles.count > 1
    end

end
