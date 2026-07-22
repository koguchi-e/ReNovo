class SituationsController < ApplicationController
  def index
    @situations = current_user.situations.order(created_at: :desc).page(params[:page])
  end

  def show
    @situation = Situation.find(params[:id])
    @tasks = @situation.tasks.order(:position)
  end

  def new
    @situation = Situation.new
  end

  def create
    @situation = Situation.new(situation_params)
    @situation.user_id = current_user.id

    if @situation.save
      GenerateTasksJob.perform_later(situation_id: @situation.id)
      redirect_to situation_tasks_path(@situation), notice: t(".created")
    else
      flash.now[:alert] = t(".alert")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def situation_params
    params.require(:situation).permit(:fact, :problem, :goal)
  end
end
