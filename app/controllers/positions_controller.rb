class PositionsController < ApplicationController
  before_action :set_situation

  def update
    @task = @situation.tasks.find(params[:task_id])
    insert_at = Integer(params[:insert_at], exception: false)

    unless insert_at&.positive?
      return render json: { error: "insert_at must be an integer of at least 1" }, status: :unprocessable_content
    end

    if @task.insert_at(insert_at)
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
