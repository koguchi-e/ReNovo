class TasksController < ApplicationController
  before_action :require_login
  before_action :set_situation
  before_action :set_task, only: %i[update destroy]

  def index
    @tasks = @situation.tasks.order(:position)
  end

  def update
    if @task.update(task_params)
      redirect_to situation_tasks_path(@situation), notice: t(".updated")
    else
      render situation_tasks_path(@situation), alert: t(".alert")
    end
  end

  def destroy
    if @task.destroy!
      redirect_to situation_tasks_path(@situation), notice: t(".destroyed")
    else
      redirect_to situation_tasks_path(@situation), alert: t(".alert")
    end
  end

  private

  def set_situation
    @situation = current_user.situations.find(params[:situation_id])
  end

  def set_task
    @task = @situation.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:content)
  end
end
