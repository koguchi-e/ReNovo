class SituationsController < ApplicationController
  before_action :set_user, only: %i[index show new create]

  def index
    @situations = current_user.situations.order(created_at: :desc).page(params[:page])
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
    if @situation.generate_tasks!
      redirect_to situation_tasks_path(@situation), notice: t(".created")
    else
      render :new, status: :unprocessable_entity, alert: t(".alert")
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
