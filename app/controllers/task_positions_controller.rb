class TaskPositionsController < ApplicationController
  before_action :require_login
  before_action :set_situation

  def update
    task_ids = params[:task_ids]
    puts task_ids
    puts task_ids.class
      ActiveRecord::Base.transaction do
        task_ids.each_with_index do |task_id, index|
          @situation.tasks.where(id: task_id).update_all(position: index + 1)
        end
      end
      redirect_to situation_completion_path(@situation)
  end

  private

  def set_situation
    @situation = current_user.situations.find(params[:situation_id])
  end
end
