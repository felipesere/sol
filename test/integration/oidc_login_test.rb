require "test_helper"

class OidcLoginTest < ActionDispatch::IntegrationTest
  setup do
    use_auth("OIDC_ISSUER" => "https://id.home", "OIDC_CLIENT_ID" => "sol", "OIDC_CLIENT_SECRET" => "x", "APP_URL" => "http://www.example.com")
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:oidc] = nil
  end

  test "login page offers a sign-in button, not names" do
    get login_path
    assert_select "form[action='/auth/oidc']"
  end

  test "a successful OIDC callback creates the user and signs them in" do
    OmniAuth.config.mock_auth[:oidc] = OmniAuth::AuthHash.new(
      provider: "oidc", uid: "sub-1", info: { name: "Anna Smith", email: "anna@home" }
    )

    assert_difference "User.count", 1 do
      post "/auth/oidc"
      follow_redirect!
      follow_redirect!
    end
    assert_select "p", text: /Anna Smith/
  end

  test "a failed OIDC callback returns to the login page" do
    OmniAuth.config.mock_auth[:oidc] = :invalid_credentials
    OmniAuth.config.on_failure = proc { |env| OmniAuth::FailureEndpoint.new(env).redirect_to_failure }

    post "/auth/oidc"
    follow_redirect!
    follow_redirect!
    assert_redirected_to login_path
  end
end
