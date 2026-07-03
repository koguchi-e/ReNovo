class SituationsController < ApplicationController
  def index
    @situations = Situation.all.order(created_at: :desc)
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
      GenerateTasksJob.perform_now(situation_id: @situation.id)
      redirect_to situation_tasks_path(@situation), notice: t(".created")
    else
      render :new, status: :unprocessable_entity, alert: t(".alert")
    end
  rescue RubyLLM::UnauthorizedError => e
    Rails.logger.error("[SituaitonsController#create] GenerateTasksJob failed: #{e.class}: #{e.message}")
    redirect_to situation_tasks_path(@situation) || situaitons_path, alert: "AIのAPIキー設定が無効です。管理者に確認してください。"
  rescue StandardError => e
    Rails.logger.error("[SituaitonsController#create] GenerateTasksJob failed: #{e.class}: #{e.message}")
    redirect_to situation_tasks_path(@situation) || situaitons_path, alert: "AIのコメントに失敗しました。時間をおいて再度お試しください。"
  end

  private

  def situation_params
    params.require(:situation).permit(:fact, :problem, :goal)
  end

  def create_tasks_by_ai
  end
end
