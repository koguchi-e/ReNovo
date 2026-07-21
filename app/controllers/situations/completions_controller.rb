class Situations::CompletionsController < ApplicationController
  before_action :set_situation

  def show
    @first_task = @situation.tasks.order(:position).first
    @tasks = @situation.tasks.order(:position)
  end

  private

  def set_situation
    @situation = current_user.situations.find(params[:situation_id])
  end
end
