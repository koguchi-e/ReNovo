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
end
