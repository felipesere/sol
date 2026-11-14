require "test_helper"

class TemperatureTest < ActiveSupport::TestCase
  def build(celsius)
    Temperature.new(child: children(:mira), user: users(:anna), measured_at: Time.current, celsius: celsius)
  end

  test "plausible readings are valid" do
    assert build(38.4).valid?
  end

  test "implausible readings are rejected" do
    assert_not build(3.8).valid?
    assert_not build(98.6).valid?
  end
end
