class TasksController < ApplicationController
  before_action :require_login
  before_action :set_situation
  before_action :set_task, only: %i[update destroy]

  def index
    @tasks = @situation.tasks.order(:position)
  end

  def update
    redirect_to situation_tasks_path(@situation), notice: t(".updated")
  end

  def destroy
    redirect_to situation_tasks_path(@situation), notice: t(".destroyed")
  end

  private

  def set_situation
    @situation = current_user.situations.find(params[:situation_id])
  end

  def set_task
    @task = @situation.task.find(params[:id])
  end
end
