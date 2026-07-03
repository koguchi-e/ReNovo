class GenerateTasksJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(situation_id:)
    situation = Situation.find_by(id: situation_id)
    return if situation.nil?

    task_contents = generate_task_contents(situation)
    return if task_contents.nil?

    task_contents.each_with_index do |content, index|
      situation.tasks.create!(
        content: content,
        position: index + 1
      )
    end
  end

  private

  def generate_task_contents(situation)
    response = TaskGenerationAgent.new.ask(promopt_for(situation))
    content = response.content.to_h

    content["tasks"] || content[:tasks]
  rescue StandardError => e
    Rails.logger.error("[GenerateTasksJob] respond failed: #{e.class}: #{e.message}")
    raise
  end

  def promopt_for(situation)
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
