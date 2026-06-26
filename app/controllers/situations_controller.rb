class SituationsController < ApplicationController
  before_action :set_user, only: %i[index show new create]

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
      created_fixed_tasks(@situation)
      redirect_to situation_tasks_path(@situation), notice: t(".created")
    else
      render :new, status: :unprocessable_entity, alert: t(".alert")
    end
  end

  private

  def situation_params
    params.require(:situation).permit(:fact, :problem, :goal)
  end

  def set_user
    @user = User.find_by(id: params[:user_id])
  end

  def created_fixed_tasks(situation)
    task_contents = [
      "会議で話した内容を3行で書き出す",
      "説明できなかった箇所を1つだけ選ぶ",
      "次回伝えたい結論を1文で書く",
      "補足が必要な情報を3つ出す",
      "次回の進捗報告で話す順番を決める"
    ]

    task_contents.each_with_index do |content, index|
      situation.tasks.create!(
        content: content,
        position: index + 1
      )
    end
  end
end
