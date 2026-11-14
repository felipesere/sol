require "test_helper"

class TimelineTest < ActiveSupport::TestCase
  setup do
    @now = Time.zone.local(2026, 11, 14, 22, 0)
    @mira = children(:mira)
  end

  def dose(minutes_ago)
    Dose.create!(child: @mira, medicine: medicines(:paracetamol), user: users(:anna), given_at: @now - minutes_ago.minutes, amount: 5)
  end

  def reading(minutes_ago)
    Temperature.create!(child: @mira, user: users(:anna), measured_at: @now - minutes_ago.minutes, celsius: 38.0)
  end

  test "splits events at 24 hours, newest first, and drops anything older than 48 hours" do
    d1 = dose(30); t1 = reading(100); d2 = dose(1500); t2 = reading(2800); dose(2900)

    timeline = Timeline.new(@mira, now: @now)

    assert_equal [d1, t1], timeline.recent.map(&:record)
    assert_equal [d2, t2], timeline.earlier.map(&:record)
  end

  test "an event exactly 24 hours old belongs to the earlier section" do
    old = dose(1440)

    assert_equal [old], Timeline.new(@mira, now: @now).earlier.map(&:record)
  end

  test "other children are not included" do
    Dose.create!(child: children(:theo), medicine: medicines(:theos_paracetamol), user: users(:anna), given_at: @now - 10.minutes, amount: 3)

    assert_empty Timeline.new(@mira, now: @now).events
  end
end
