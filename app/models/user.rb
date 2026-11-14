class User < ApplicationRecord
  validates :name, presence: true

  def self.from_oidc(auth)
    user = find_or_initialize_by(sub: auth.uid)
    user.name = auth.info.name.presence || auth.info.nickname.presence || auth.info.email.presence || "Unknown"
    user.email = auth.info.email
    user.save!
    user
  end

  # Household users have no OIDC subject; they are identified by their configured name.
  def self.household(name)
    find_or_create_by!(name: name, sub: nil)
  end
end
