# Decides how people log in, based on environment variables.
#
#   HOUSEHOLD_USERS="Felipe,Anna"   pick-your-name login, no OIDC
#   OIDC_ISSUER / OIDC_CLIENT_ID / OIDC_CLIENT_SECRET / APP_URL   OIDC login (e.g. PocketID)
class AuthConfig
  class Invalid < StandardError; end

  OIDC_KEYS = %w[OIDC_ISSUER OIDC_CLIENT_ID OIDC_CLIENT_SECRET APP_URL].freeze

  def initialize(env)
    @env = env
  end

  def household_names
    @household_names ||= @env.fetch("HOUSEHOLD_USERS", "").split(",").map(&:strip).reject(&:empty?).uniq
  end

  def household?
    household_names.any?
  end

  def oidc?
    !household? && OIDC_KEYS.all? { |key| @env[key].to_s != "" }
  end

  def mode
    return :household if household?
    return :oidc if oidc?

    :none
  end

  def oidc_settings
    {
      issuer: @env["OIDC_ISSUER"],
      identifier: @env["OIDC_CLIENT_ID"],
      secret: @env["OIDC_CLIENT_SECRET"],
      redirect_uri: "#{@env["APP_URL"].to_s.chomp("/")}/auth/oidc/callback"
    }
  end

  def validate!
    return unless mode == :none

    missing = OIDC_KEYS.reject { |key| @env[key].to_s != "" }
    raise Invalid, "Set HOUSEHOLD_USERS (e.g. \"Felipe,Anna\") or configure OIDC. Missing for OIDC: #{missing.join(", ")}"
  end
end
