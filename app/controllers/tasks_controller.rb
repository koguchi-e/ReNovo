# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :set_situation
  before_action :set_task, only: %i[update destroy]
  before_action :fail_timed_out_generation, only: :index

  def index
    @tasks = @situation.tasks.order(:position)
    @new_task = @situation.tasks.build
  end

  def create
    @new_task = @situation.tasks.build(task_params)
    @new_task.position = @situation.tasks.maximum(:position).to_i + 1
    if @new_task.save
      @situation.completed! if @situation.failed?
      render_task_list(notice: t(".created"))
    else
      redirect_to situation_tasks_path(@situation), alert: t(".alert")
    end
  end

  def update
    if @task.update(task_params)
      render_task_list(notice: t(".updated"))
    else
      redirect_to situation_tasks_path(@situation), alert: t(".alert")
    end
  end

  def destroy
    if @task.destroy
      render_task_list(notice: t(".destroyed"))
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

    def fail_timed_out_generation
      @situation.with_lock do
        @situation.reload

        @situation.failed! if @situation.generation_timed_out?
      end
    end

    def render_task_list(notice:)
      render turbo_stream: [
        turbo_stream.update(
          "status_screen",
          partial: "tasks/list",
          locals: {
            situation: @situation,
            tasks: @situation.tasks.order(:position),
            new_task: @situation.tasks.build
          }
        ),
        turbo_stream.update(
          "flash_messages",
          partial: "shared/flash",
          locals: {
            type: :notice,
            message: notice
          }
        )
      ]
    end
end
