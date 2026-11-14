require Rails.root.join("lib/auth_config")

env = ENV.to_h
# Local development works out of the box with two household users.
env["HOUSEHOLD_USERS"] ||= "Felipe,Anna" if Rails.env.development? && !AuthConfig.new(env).oidc?

Rails.configuration.x.auth = AuthConfig.new(env)
Rails.configuration.x.auth.validate! unless Rails.env.test? || ENV["SECRET_KEY_BASE_DUMMY"]
