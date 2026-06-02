class HomeController < ApplicationController
  before_action :require_login, only: :show

  def index
  end

  def show
  end

  private

  def require_login
    redirect_to root_path unless current_user
  end
end
