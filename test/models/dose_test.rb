require "test_helper"

class DoseTest < ActiveSupport::TestCase
  def build(**attrs)
    Dose.new({ child: children(:mira), medicine: medicines(:paracetamol), user: users(:anna), given_at: Time.current, amount: 5 }.merge(attrs))
  end

  test "valid dose" do
    assert build.valid?
  end

  test "medicine must belong to the child" do
    assert_not build(child: children(:theo)).valid?
  end

  test "amount must be positive" do
    assert_not build(amount: 0).valid?
  end
end
