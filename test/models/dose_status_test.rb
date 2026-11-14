require "test_helper"

class DoseStatusTest < ActiveSupport::TestCase
  setup do
    @now = Time.zone.local(2026, 11, 14, 22, 0)
    @medicine = medicines(:paracetamol) # every 4h, max 4 per 24h
  end

  def give(minutes_ago, medicine: @medicine)
    Dose.create!(child: medicine.child, medicine: medicine, user: users(:anna),
                 given_at: @now - minutes_ago.minutes, amount: medicine.dose_amount)
  end

  def status(medicine = @medicine)
    DoseStatus.new(medicine, now: @now)
  end

  test "no doses means ok right now" do
    assert_equal :ok, status.state
    assert_equal 0, status.count
    assert_equal 4, status.remaining
    assert_nil status.last_dose
    assert_equal @now, status.next_allowed_at
  end

  test "inside the minimum interval it waits until the interval ends" do
    give(150)

    assert_equal :wait, status.state
    assert_equal @now + 90.minutes, status.next_allowed_at
  end

  test "exactly at the interval it is ok again" do
    give(240)

    assert_equal :ok, status.state
  end

  test "one minute before the interval ends it still waits" do
    give(239)

    assert_equal :wait, status.state
  end

  test "reaching the maximum blocks, even after the interval has passed" do
    give(1300); give(900); give(500); give(300)

    assert_equal :limit, status.state
    assert_equal 0, status.remaining
  end

  test "when limited, the next dose waits for the oldest dose to leave the window" do
    give(1300); give(900); give(500); give(300)

    assert_equal @now - 1300.minutes + 24.hours, status.next_allowed_at
  end

  test "when limited, the interval can be the later constraint" do
    give(1430); give(900); give(500); give(10)

    # oldest leaves in 10 minutes but the last dose blocks for 230 more
    assert_equal @now + 230.minutes, status.next_allowed_at
  end

  test "doses older than 24 hours do not count" do
    give(1441); give(1500); give(2000)

    assert_equal 0, status.count
    assert_equal :ok, status.state
  end

  test "a dose exactly 24 hours old has left the window" do
    give(1440)

    assert_equal 0, status.count
  end

  test "doses of other medicines do not count" do
    give(10, medicine: medicines(:ibuprofen))

    assert_equal :ok, status.state
  end

  test "doses for other children do not count" do
    give(10, medicine: medicines(:theos_paracetamol))

    assert_equal :ok, status.state
  end

  test "remaining counts down" do
    give(900); give(500)

    assert_equal 2, status.remaining
  end

  test "backdated doses are respected" do
    give(600)

    assert_equal :ok, status.state
    assert_equal 600.minutes.ago(@now), status.last_dose.given_at
  end
end
