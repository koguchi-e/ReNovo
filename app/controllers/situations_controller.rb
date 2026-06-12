class SituationsController < ApplicationController
  before_action :set_user, only: %i[index show new create]

  def index
  end

  def show
    @situation = Situation.find(params[:id])
  end

  def new
    @situation = Situation.new
  end

  def create
    @situation = Situation.new(situation_params)
    @situation.user_id = current_user.id
    if @situation.save
      redirect_to situation_path(@situation.id), notice: t(".created")
    else
      render :new, status: :unprocessable_entity, notice: t(".alert")
    end
  end

  private

  def situation_params
    params.require(:situation).permit(:fact, :problem, :goal)
  end

  def set_user
    @user = User.find_by(id: params[:user_id])
  end
end
