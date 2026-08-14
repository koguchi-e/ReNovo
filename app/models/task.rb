# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :situation

  acts_as_list scope: :situation

  validates :content, presence: true
end
