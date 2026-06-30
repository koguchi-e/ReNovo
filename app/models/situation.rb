class Situation < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  validates :fact, presence: true, length: { maximum: 300 }
  validates :problem, presence: true, length: { maximum: 300 }
  validates :goal, presence: true, length: { maximum: 300 }

  enum :status, {
    pending: 0,
    generating: 1,
    completed: 2,
    failed: 3
  }

  def generate_tasks!
    task_contents = generete_task_contents
    transaction do
      tasks.destroy_all

      task_contents.each_with_index do |content, index|
        tasks.create!(
          content: content,
          position: index + 1
        )
      end
    end
  end

  private

  def openai_client
    OpenAI::Client.new(
      api_key: Rails.application.credentials.openai[:api_key]
    )
  end

  def generete_task_contents
    response = openai_client.responses.create(
      model: "gpt-4o-mini",
      input: ai_prompt
    )
    response.output_text.lines.map(&:strip).reject(&:blank?)
  end

  def ai_prompt
    <<~PROMPT
      あなたはユーザーが入力した状況、問題、目標を元に
      次に行う小さいタスクを作成してください。

      ユーザーを分析したり説教したりしません。

      目的は、
      「考えすぎて止まっている人」が
      次の小さい行動に移れるよう支援することです。

      以下ルールを守ってください。

      - タスクは5つだけ出力し、箇条書きなどにはしないでください。
      - 医療的判断をしないでください
      - 人生アドバイスをしないでください
      - タスクだけ出力してください
        - 長文を書かないでください
        - 原因分析をしないでください
        - 励ましは書かないでください
      - タスクは5〜15分で終わるサイズ
      - 必要な場合は、〇回・〇分・〇時など、具体的な回数や時刻も入れてください
      - 「学ぶ」「理解する」「動く」など抽象的な表現を避け、具体的に何をすべきかを書く
      - タスクはユーザーが入れ替えることができるので、「次に」「最後に」など順番を意識させる接続詞はつけないでください
      - 簡単で優先度の高い順に出してください
      - タスクは1つずつ改行して出力してください

      入力形式：
      状況:
      #{fact}

      問題:
      #{problem}

      目標:
      #{goal}
    PROMPT
  end
end
