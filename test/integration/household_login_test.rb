require "test_helper"

class HouseholdLoginTest < ActionDispatch::IntegrationTest
  setup { use_auth("HOUSEHOLD_USERS" => "Felipe,Anna") }

  test "anonymous visitors are sent to the picker" do
    get root_path
    assert_redirected_to login_path
  end

  test "picker lists every configured name" do
    get login_path
    assert_select "button", text: "Felipe"
    assert_select "button", text: "Anna"
  end

  test "choosing a name signs in and remembers them" do
    post session_path, params: { name: "Anna" }
    assert_redirected_to root_path

    follow_redirect!
    assert_select "p", text: /Anna/
    assert cookies[:user_id].present?
  end

  test "names outside the configured list are rejected" do
    post session_path, params: { name: "Mallory" }

    assert_redirected_to login_path
    assert_nil User.find_by(name: "Mallory")
  end

  test "a user removed from the list loses access" do
    post session_path, params: { name: "Anna" }
    use_auth("HOUSEHOLD_USERS" => "Felipe")

    get root_path
    assert_redirected_to login_path
  end

  test "switching person signs out" do
    post session_path, params: { name: "Anna" }
    delete session_path
    get root_path
    assert_redirected_to login_path
  end
end
