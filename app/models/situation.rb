# frozen_string_literal: true

class Situation < ApplicationRecord
  GENERATION_TIMEOUT = 5.minutes

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

  def generation_timed_out?
    pending? && created_at < GENERATION_TIMEOUT.ago
  end
end
