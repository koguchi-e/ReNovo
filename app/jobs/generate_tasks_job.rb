class GenerateTasksJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(situation_id:)
    situation = Situation.find_by(id: situation_id)
    return if situation.nil?

    task_contents = TaskGenerationAgent.generate(situation)
    return if task_contents.nil?

    ActiveRecord::Base.transaction do
      task_contents.each_with_index do |content, index|
        situation.tasks.create!(
          content: content,
          position: index + 1
        )
      end
    end
  rescue StandardError => e
    Rails.logger.error("[GenerateTasksJob] respond failed: #{e.class}: #{e.message}")
    raise
  end
end
