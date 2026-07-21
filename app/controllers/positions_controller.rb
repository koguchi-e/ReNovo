class PositionsController < ApplicationController
  before_action :require_login
  before_action :set_situation

  def edit
    @tasks = @situation.tasks.order(:position)
  end

  def update
    @task = @situation.tasks.find(params[:task_id])

    if @task.insert_at(params[:insert_at])
      head :no_content
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  private

  def set_situation
    @situation = current_user.situations.find(params[:situation_id])
  end
end
