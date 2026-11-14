auth = Rails.configuration.x.auth

if auth.oidc? || Rails.env.test?
  settings = auth.oidc? ? auth.oidc_settings : { issuer: "https://id.example.test", identifier: "test", secret: "test", redirect_uri: "http://www.example.com/auth/oidc/callback" }

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :openid_connect,
      name: :oidc,
      scope: %i[openid email profile],
      response_type: :code,
      discovery: true,
      issuer: settings[:issuer],
      client_options: settings.slice(:identifier, :secret, :redirect_uri)
  end

  OmniAuth.config.allowed_request_methods = %i[post]
  OmniAuth.config.logger = Rails.logger
end
