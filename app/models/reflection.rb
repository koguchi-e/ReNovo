class Reflection < ApplicationRecord
  belongs_to :user

  validates :situation, presence: true
  validates :problem, presence: true
  validates :goal, presence: true

  enum :status, {
    pending: 0,
    generating: 1,
    completed: 2,
    failed: 3
  }
end
