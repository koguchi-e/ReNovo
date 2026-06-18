class User < ApplicationRecord
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
end
