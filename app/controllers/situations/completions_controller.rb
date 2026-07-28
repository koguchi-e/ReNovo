class Situations::CompletionsController < ApplicationController
  before_action :set_situation
  before_action :redirect_if_no_tasks, only: :show

  def show
    @first_task = @situation.tasks.order(:position).first
    @tasks = @situation.tasks.order(:position)
  end

  private

  def set_situation
    @situation = current_user.situations.find(params[:situation_id])
  end

  def redirect_if_no_tasks
    return if @situation.tasks.exists?

    redirect_to situation_tasks_path(@situation), alert: "タスクがありません"
  end
end
