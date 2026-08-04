class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :create ]

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_from_auth_hash(auth)
    session[:user_id] = user.id
    redirect_to new_situation_path, notice: "ログインしました。"
  end

  def destroy
    reset_session

    redirect_to root_path, notice: "ログアウトしました。"
  end
end
