# frozen_string_literal: true

class Tasks::PositionsController < ApplicationController
  before_action :set_situation

  def update
    @task = @situation.tasks.find(params[:task_id])

    if @task.insert_at(params[:insert_at])
      head :no_content
    else
      head :unprocessable_content
    end
  end

  private
    def set_situation
      @situation = current_user.situations.find(params[:situation_id])
    end
end
