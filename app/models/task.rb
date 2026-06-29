class Task < ApplicationRecord
  belongs_to :situation

  validates :content, presence: true
  validates :position, presence: true
end
