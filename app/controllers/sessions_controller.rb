# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[create developer_create]

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_from_auth_hash(auth)
    session[:user_id] = user.id
    redirect_to new_situation_path, notice: "ログインしました。"
  end

  def developer_create
    head :not_found and return unless Rails.env.development?

    user = User.find_or_create_by!(
      provider: "developer",
      uid: "local-reviewer"
    ) do |developer|
      developer.email_address = "review@example.test"
      developer.name = "ローカルレビューユーザー"
    end

    session[:user_id] = user.id
    redirect_to new_situation_path, notice: "開発用ユーザーでログインしました。"
  end

  def destroy
    reset_session

    redirect_to root_path, notice: "ログアウトしました。"
  end
end
