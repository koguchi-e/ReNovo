# frozen_string_literal: true

class User < ApplicationRecord
  MONTHLY_USAGE_LIMIT = 50

  has_many :situations, dependent: :destroy

  def self.find_or_create_from_auth_hash(auth)
    find_or_create_by!(
      provider: auth.provider,
      uid: auth.uid
    ) do |user|
      user.email_address = auth.info.email_address
      user.name = auth.info.name
    end
  end

  def monthly_usage_limit_reached?
    situations.where(created_at: Time.current.all_month).count >= MONTHLY_USAGE_LIMIT
  end
end
