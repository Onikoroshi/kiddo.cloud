class StaticController < ApplicationController

  def home
    if user_signed_in?
      if current_user.roles.any?
        url = Receptionist.new(current_user, @center).direct
        ap "redirecting to #{url}"
        redirect_to url and return
      else
        sign_out(current_user)
        flash[:error] = "You do not appear to have any roles assigned."
        ap "redirecting to new user session url: #{new_user_session_url}"
        redirect_to new_user_session_url and return
      end
    else
      ap "redirecting to new user session url: #{new_user_session_url}"
      # redirect_to new_user_session_url and return
      redirect_to new_user_registration_url and return
    end
  end

  def dkk
  end

  def material
    render layout: "material"
  end

end
