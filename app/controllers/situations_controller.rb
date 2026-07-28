class SituationsController < ApplicationController
  MONTHLY_USAGE_LIMIT = 50

  def index
    @situations = current_user.situations.order(created_at: :desc).page(params[:page])
  end

  def show
    @situation = current_user.situations.find(params[:id])
    @tasks = @situation.tasks.order(:position)
    @new_task = @situation.tasks.build
  end

  def new
    @situation = Situation.new
  end

  def create
    @situation = current_user.situations.build(situation_params)

    if monthly_usage_limit_reached?
      flash.now[:alert] = "今月の利用上限に達しました。翌月に再び利用できます。"
      render :new, status: :too_many_requests
      return
    end

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

  def monthly_usage_limit_reached?
    current_user.situations.where(created_at: Time.current.all_month).count >= MONTHLY_USAGE_LIMIT
  end
end
