class GenerateTasksJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(situation_id:)
    situation = Situation.find_by(id: situation_id)
    return if situation.nil?

    situation.generating!

    task_contents = TaskGenerationAgent.generate(situation)

    unless task_contents.is_a?(Array) && task_contents.size == 5 && task_contents.all?(&:present?)
      situation.failed!
      Rails.logger.error("[GenerateTasksJob] invalid task content: #{task_contents.inspect}")
      return
    end

    ActiveRecord::Base.transaction do
      task_contents.each_with_index do |content, index|
        situation.tasks.create!(
          content: content,
          position: index + 1
        )
      end
      situation.completed!
    end
  rescue StandardError => e
    situation&.failed!
    Rails.logger.error("[GenerateTasksJob] failed: #{e.class}: #{e.message}")
    raise
  end
end
