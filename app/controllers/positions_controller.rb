# frozen_string_literal: true

class PositionsController < ApplicationController
  before_action :set_situation
  before_action :redirect_if_no_tasks, only: :edit

  def edit
    @tasks = @situation.tasks.order(:position)
  end

  def update
    @task = @situation.tasks.find(params[:task_id])

    if @task.insert_at(params[:insert_at])
      head :no_content
    end
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
