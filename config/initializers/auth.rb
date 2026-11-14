require Rails.root.join("lib/auth_config")

Rails.configuration.x.auth = AuthConfig.new(ENV)
Rails.configuration.x.auth.validate! unless Rails.env.test? || ENV["SECRET_KEY_BASE_DUMMY"]
