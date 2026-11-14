require "test_helper"

class UserTest < ActiveSupport::TestCase
  Auth = Struct.new(:uid, :info)
  Info = Struct.new(:name, :email, :nickname)

  def oidc(uid: "abc", name: "Anna Smith", email: "anna@home")
    Auth.new(uid, Info.new(name, email, nil))
  end

  test "name is required" do
    assert_not User.new.valid?
  end

  test "from_oidc creates a user the first time" do
    assert_difference "User.count", 1 do
      user = User.from_oidc(oidc)
      assert_equal "Anna Smith", user.name
      assert_equal "abc", user.sub
    end
  end

  test "from_oidc updates the existing user instead of duplicating" do
    User.from_oidc(oidc)

    assert_no_difference "User.count" do
      assert_equal "Anna S.", User.from_oidc(oidc(name: "Anna S.")).name
    end
  end

  test "from_oidc falls back to email when there is no name" do
    assert_equal "anna@home", User.from_oidc(oidc(name: nil)).name
  end

  test "household finds or creates by name" do
    assert_difference "User.count", 1 do
      User.household("Felipe")
      User.household("Felipe")
    end
  end
end
