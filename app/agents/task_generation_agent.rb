# frozen_string_literal: true

class TaskGenerationAgent < RubyLLM::Agent
  SYSTEM_PROMPT = <<~PROMPT
    あなたはユーザーが入力した状況、問題、目標を元に
    次に行う小さいタスクを作成してください。

    ユーザーを分析したり説教したりしません。

    目的は、
    「考えすぎて止まっている人」が
    次の小さい行動に移れるよう支援することです。

    以下ルールを守ってください。

    - タスクは5つだけ出力し、箇条書きなどにはしないでください。
    - 診断、治療、服薬に関する判断や助言をしないでください
    - 自傷、自殺、他者への暴力を促したり、具体的な方法や手順を提案したりしないでください
    - 自傷、自殺、他害のおそれがある入力には、危険な行動を避け、安全な場所への移動や、信頼できる人・公的な相談先への連絡につながる行動のみを提案してください
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
  PROMPT

  schema TaskGenerationResponse
  instructions SYSTEM_PROMPT

  def self.generate(situation)
    response = new.ask(prompt_for(situation))
    content = response.content.to_h

    content.fetch("tasks") { content.fetch(:tasks) }
  end

  def self.prompt_for(situation)
    <<~PROMPT
      入力形式：
      状況:
      #{situation.fact}

      問題:
      #{situation.problem}

      目標:
      #{situation.goal}
    PROMPT
  end
end
