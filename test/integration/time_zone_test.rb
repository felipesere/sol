require "test_helper"

class TimeZoneTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as "Anna"
    @mira = children(:mira)
    @para = medicines(:paracetamol)
  end

  # In November Madrid is UTC+1, so 22:30 on the wall clock is 21:30 UTC.
  test "a dose entered at 22:30 on the browser's clock is stored as that moment" do
    cookies[:timezone] = "Europe/Madrid"

    post child_doses_path(@mira), params: { dose: { medicine_id: @para.id, amount: 5, given_at: "2026-11-14T22:30" } }

    assert_equal Time.utc(2026, 11, 14, 21, 30), Dose.last.given_at
  end

  test "the same dose is shown as 22:30 and pre-fills 22:30 when editing" do
    dose = Dose.create!(child: @mira, medicine: @para, user: users(:anna), given_at: Time.utc(2026, 11, 14, 21, 30), amount: 5)
    cookies[:timezone] = "Europe/Madrid"

    travel_to Time.utc(2026, 11, 14, 22, 0) do
      get child_path(@mira)
      assert_select "a[href$='/doses/#{dose.id}/edit']", text: /22:30/

      get edit_child_dose_path(@mira, dose)
      assert_select "input[name='dose[given_at]'][value='2026-11-14T22:30']"
    end
  end

  test "a temperature round-trips on the browser's clock" do
    cookies[:timezone] = "America/New_York"

    post child_temperatures_path(@mira), params: { temperature: { celsius: "38.1", measured_at: "2026-11-14T08:15" } }

    assert_equal Time.utc(2026, 11, 14, 13, 15), Temperature.last.measured_at
  end

  test "without a cookie the configured zone applies" do
    post child_doses_path(@mira), params: { dose: { medicine_id: @para.id, amount: 5, given_at: "2026-11-14T22:30" } }

    assert_equal Time.zone.local(2026, 11, 14, 22, 30), Dose.last.given_at
  end

  test "an invalid zone in the cookie is ignored" do
    cookies[:timezone] = "Mars/Olympus"

    post child_doses_path(@mira), params: { dose: { medicine_id: @para.id, amount: 5, given_at: "2026-11-14T22:30" } }

    assert_equal Time.zone.local(2026, 11, 14, 22, 30), Dose.last.given_at
  end

  test "pages load the controller that reports the browser's zone" do
    get child_path(@mira)

    assert_select "body[data-controller=timezone]"
  end

  test "the zone does not leak into later requests" do
    cookies[:timezone] = "Asia/Tokyo"
    get child_path(@mira)

    assert_equal "UTC", Time.zone.name
  end
end
