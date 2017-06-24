class ReceptionistController < ApplicationController
  before_action :redirect_without_multiple_roles

  def index
    @receptionist = Receptionist.new(current_user, @center)
  end

  private

    def redirect_without_multiple_roles
      redirect_to root_path unless user_signed_in? && current_user.roles.count > 1
    end

end
