# frozen_string_literal: true

class GenerateTasksJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(situation_id:)
    situation = Situation.find_by(id: situation_id)
    return if situation.nil?

    begin
      Turbo::StreamsChannel.broadcast_replace_to(
        situation,
        target: "status_screen",
        partial: "tasks/generating",
        locals: { situation: situation }
      )

      task_contents = TaskGenerationAgent.generate(situation)

      unless task_contents.is_a?(Array) && task_contents.size == 5 && task_contents.all?(&:present?)
        situation.failed!
        Rails.logger.error("[GenerateTasksJob] invalid task content: #{task_contents.inspect}")
        Turbo::StreamsChannel.broadcast_replace_to(
          situation,
          target: "status_screen",
          partial: "tasks/failed",
          locals: { situation: situation }
        )
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

      Turbo::StreamsChannel.broadcast_replace_to(
        situation,
        target: "status_screen",
        partial: "tasks/status_screen",
        locals: {
          situation: situation,
          tasks: situation.tasks.order(:position),
          new_task: situation.tasks.build,
          open_new_task_form: false
        }
      )
    rescue StandardError => e
      situation&.failed! unless situation.completed?
      Rails.logger.error("[GenerateTasksJob] failed: #{e.class}: #{e.message}")
      Turbo::StreamsChannel.broadcast_replace_to(
        situation,
        target: "status_screen",
        partial: "tasks/failed",
        locals: { situation: situation }
      )
      raise
    end

  end
end
