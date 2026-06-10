class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:create]

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_from_auth_hash(auth)
    session[:user_id] = user.id
     redirect_to "/home"
  end

  def destroy
    reset_session

    redirect_to root_path
  end
end
