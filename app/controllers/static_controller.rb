class StaticController < ApplicationController

  def home
    if user_signed_in?
      if current_user.roles.any?
        redirect_to Receptionist.new(current_user, @center).direct and return
      else
        sign_out(current_user)
        flash[:error] = "You do not appear to have any roles assigned."
        redirect_to new_user_session_url and return
      end
    else
      redirect_to new_user_session_url and return
    end
  end

  def dkk
  end

  def material
    render layout: "material"
  end

end
