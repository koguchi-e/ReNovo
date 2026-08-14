# frozen_string_literal: true

class TaskGenerationsController < ApplicationController
  def create
    situation = current_user.situations.find(params[:situation_id])

    enqueued = situation.with_lock do
      if situation.failed?
        situation.generating!
        GenerateTasksJob.perform_later(situation_id: situation.id)
        true
      else
        false
      end
    end

    if enqueued
      redirect_to situation_tasks_path(situation)
    else
      redirect_to situation_tasks_path(situation), alert: "現在タスクの再生成はできません。"
    end
  end
end
