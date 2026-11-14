require "test_helper"

class AuthConfigTest < ActiveSupport::TestCase
  OIDC = { "OIDC_ISSUER" => "https://id.home", "OIDC_CLIENT_ID" => "sol", "OIDC_CLIENT_SECRET" => "s3cret", "APP_URL" => "https://sol.home/" }

  test "household mode when HOUSEHOLD_USERS is set" do
    config = AuthConfig.new("HOUSEHOLD_USERS" => " Felipe, Anna ,,Felipe")

    assert_equal :household, config.mode
    assert_equal %w[Felipe Anna], config.household_names
  end

  test "household mode wins over OIDC settings" do
    assert_equal :household, AuthConfig.new(OIDC.merge("HOUSEHOLD_USERS" => "Anna")).mode
  end

  test "oidc mode when all OIDC settings are present" do
    config = AuthConfig.new(OIDC)

    assert_equal :oidc, config.mode
    assert_equal "https://sol.home/auth/oidc/callback", config.oidc_settings[:redirect_uri]
  end

  test "partial OIDC settings are not enough" do
    config = AuthConfig.new(OIDC.except("APP_URL"))

    assert_equal :none, config.mode
    error = assert_raises(AuthConfig::Invalid) { config.validate! }
    assert_includes error.message, "APP_URL"
  end

  test "nothing configured is invalid" do
    assert_raises(AuthConfig::Invalid) { AuthConfig.new({}).validate! }
  end
end
