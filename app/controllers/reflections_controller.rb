class ReflectionsController < ApplicationController
  def index
  end

  def show
    @reflection = Reflection.find(params[:id])
  end

  def new
    @reflection = Reflection.new
  end

  def create
    @reflection = Reflection.new(reflection_params)
    @reflection.user_id = current_user.id
    @reflection.save
    # エラーハンドリングする
    redirect_to reflection_path(@reflection.id)
  end

  private

  def reflection_params
    params.require(:reflection).permit(:situation, :problem, :goal)
  end

  def set_user
    @user = User.find_by(id: params[:user_id])
  end
end
