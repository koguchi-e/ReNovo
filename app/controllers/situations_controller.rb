class SituationsController < ApplicationController
  def index
    @situations = current_user.situations.order(created_at: :desc).page(params[:page])
  end

  def show
    @situation = Situation.find(params[:id])
  end

  def new
    @situation = Situation.new
  end

  def create
    @situation = Situation.new(situation_params)
    @situation.user_id = current_user.id

    if @situation.save
      begin
        GenerateTasksJob.perform_later(situation_id: @situation.id)
        redirect_to situation_tasks_path(@situation), notice: t(".created")
      rescue RubyLLM::UnauthorizedError => e
        Rails.logger.error("[SituationsController#create] GenerateTasksJob failed: #{e.class}: #{e.message}")
        redirect_to situation_tasks_path(@situation), alert: "AIのAPIキー設定が無効です。管理者に確認してください。"
      rescue StandardError => e
        Rails.logger.error("[SituationsController#create] GenerateTasksJob failed: #{e.class}: #{e.message}")
        redirect_to situation_tasks_path(@situation), alert: "AIのコメントに失敗しました。時間をおいて再度お試しください。"
      end
    else
      flash.now[:alert] = t(".alert")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def situation_params
    params.require(:situation).permit(:fact, :problem, :goal)
  end
end
