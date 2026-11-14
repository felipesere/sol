require "test_helper"

class ThemeTest < ActionDispatch::IntegrationTest
  setup { sign_in_as "Anna" }

  test "defaults to auto, so the OS preference decides" do
    get child_path(children(:mira))

    assert_select "html[data-theme]", count: 0
    assert_select "header form[action='/theme'] button", text: "Auto"
  end

  test "choosing a theme is remembered and set on the html element" do
    patch theme_path, params: { theme: "dark" }, headers: { "HTTP_REFERER" => child_url(children(:mira)) }
    assert_redirected_to child_path(children(:mira))

    follow_redirect!
    assert_select "html[data-theme=dark]"
    assert_select "header form[action='/theme'] button", text: "Dark"
  end

  test "the toggle cycles auto, light, dark and back" do
    get child_path(children(:mira))
    assert_select "header form[action='/theme'] input[name=theme][value=light]"

    patch theme_path, params: { theme: "light" }
    get child_path(children(:mira))
    assert_select "header form[action='/theme'] input[name=theme][value=dark]"

    patch theme_path, params: { theme: "dark" }
    get child_path(children(:mira))
    assert_select "header form[action='/theme'] input[name=theme][value=auto]"
  end

  test "the toggle bypasses Turbo so the html attribute is refreshed" do
    get child_path(children(:mira))

    assert_select "header form[action='/theme'][data-turbo=false]"
  end

  test "unknown values fall back to auto" do
    patch theme_path, params: { theme: "neon" }
    get child_path(children(:mira))

    assert_select "html[data-theme]", count: 0
  end
end
