# frozen_string_literal: true

class SituationsController < ApplicationController
  MONTHLY_USAGE_LIMIT = 50

  def index
    @situations = current_user.situations.order(created_at: :desc).page(params[:page])
  end

  def show
    @situation = current_user.situations.find(params[:id])
    @tasks = @situation.tasks.order(:position)
    @new_task = @situation.tasks.build
    @first_task = @tasks.first
  end

  def new
    @situation = Situation.new
    @usage_limit_reached = monthly_usage_limit_reached?
  end

  def create
    @situation = current_user.situations.build(situation_params)

    limit_reached = false
    saved = false

    current_user.with_lock do
      if monthly_usage_limit_reached?
        limit_reached = true
      else
        saved = @situation.save
      end
    end

    if limit_reached
      flash.now[:alert] = "今月の利用上限に達しました。翌月に再び利用できます。"
      @usage_limit_reached = true
      render :new, status: :too_many_requests
    elsif saved
      GenerateTasksJob.perform_later(situation_id: @situation.id)
      redirect_to situation_tasks_path(@situation), notice: t(".created")
    else
      flash.now[:alert] = t(".alert")
      @usage_limit_reached = false
      render :new, status: :unprocessable_content
    end
  end

  private
    def situation_params
      params.require(:situation).permit(:fact, :problem, :goal)
    end

    def monthly_usage_limit_reached?
      current_user.situations.where(created_at: Time.current.all_month).count >= MONTHLY_USAGE_LIMIT
    end
end
